(function() {
  'use strict';

  const IMGS_CAPSULE_L = [null, null, null];
  const IMGS_CAPSULE_R = [null, null, null];
  const IMGS_VIRUS     = [null, null, null];

  function BIT(x, i) {
    return (x>>i) & 1;
  }

  function rand_update(r) {
    const bit = BIT(r,1) ^ BIT(r,9);
    r >>>= 1;
    r   |= bit << 15;
    return r;
  }

  function rand_at(n) {
    let r = 0x8988;
    for(let i = 0; i < n; ++i) {
      r = rand_update(r);
    }
    return r;
  }

  function gen_tumos(r) {
    const tumos = [];
    for(let i = 0, x = 0; i < 128; ++i) {
      r = rand_update(r);
      x += (r>>8) & 0xF;
      while(x >= 9) x -= 9;
      tumos.push(x);
    }
    tumos.reverse();

    // 0番目はスキップされるのでここで補正してしまう
    tumos.push(tumos.shift());

    return [tumos, r];
  }

  function virus_put(level, r, c, field) {
    const H_MAX = [
       9,  9,  9,  9,  9,  9,  9,  9,  9,  9,
       9,  9,  9,  9,  9, 10, 10, 11, 11, 12,
      12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
      12, 12, 12, 12, 12,
    ];
    const COLORS = [
      0, 1, 2, 2, 1, 0, 0, 1,
      2, 2, 1, 0, 0, 1, 2, 1,
    ];
    const MASKS = [ 1, 2, 4, 0 ];

    let h = null;
    while(true) {
      r = rand_update(r);
      h = (r>>8) & 0xF;
      if(h <= H_MAX[level]) break;
    }

    const x = (r&0xFF) & 7;
    const y = 15 - h;
    let off = 8*y + x;

    let color = c & 3;
    if(color === 3) {
      r = rand_update(r);
      color = COLORS[(r&0xFF) & 0xF];
    }

    while(true) {
      while(field[off] !== 0xFF) {
        ++off;
        if(off >= 128) return [r, false];
      }

      let mask = 0;
      mask |= MASKS[field[off-16] & 3];
      if(off < 112)
        mask |= MASKS[field[off+16] & 3];
      if(off % 8 >= 2)
        mask |= MASKS[field[off-2] & 3];
      if(off % 8 < 6)
        mask |= MASKS[field[off+2] & 3];

      if(mask === 7) {
        ++off;
        if(off >= 128) return [r, false];
        continue;
      }

      while((MASKS[color] & mask) !== 0) {
        --color;
        if(color < 0) color = 2;
      }

      field[off] = 0xD0 | color;
      return [r, true];
    }
  }

  function gen_field(level, r) {
    const field = [];
    for(let i = 0; i < 128; ++i)
      field[i] = 0xFF;

    let count = 4 * (level+1);
    while(count > 0) {
      let success = null;
      [r, success] = virus_put(level, r, count, field);
      if(success) --count;
    }

    return [field, r];
  }

  function gen_hand(level, r) {
    let tumos = null;
    let field = null;

    [tumos, r] = gen_tumos(r);
    [field, r] = gen_field(level, r);

    return [tumos, field, r];
  }

  function draw_tumos(ctx, tumos) {
    const CAPSULE_L = [ 0, 0, 0, 1, 1, 1, 2, 2, 2 ];
    const CAPSULE_R = [ 0, 1, 2, 0, 1, 2, 0, 1, 2 ];

    for(let i = 0; i < 128; ++i) {
      const t = tumos[i];
      const l = CAPSULE_L[t];
      const r = CAPSULE_R[t];

      const x = 72 + 16 * Math.floor(i/16);
      const y = 8 * (i%16);

      ctx.drawImage(IMGS_CAPSULE_L[l], x,   y);
      ctx.drawImage(IMGS_CAPSULE_R[r], x+8, y);
    }
  }

  function draw_field(ctx, field) {
    for(let r = 0; r < 16; ++r) {
      for(let c = 0; c < 8; ++c) {
        const off = 8*r + c;
        const cell = field[off];
        if(cell === 0xFF) continue;

        const color = cell & 0xF;
        ctx.drawImage(IMGS_VIRUS[color], 8*c, 8*r);
      }
    }
  }

  function draw_hand(level, tumos, field) {
    const canvas = document.getElementById('canvas_' + level);
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'white';
    ctx.fillRect(64, 0, 8, 128);

    draw_tumos(ctx, tumos);
    draw_field(ctx, field);
  }

  function simulate(r) {
    for(let level = 0; level <= 20; ++level) {
      let tumos = null;
      let field = null;

      [tumos, field, r] = gen_hand(level, r);
      draw_hand(level, tumos, field);
    }
  }

  function update(elem) {
    const rand_idx = parseInt(elem.value, 10);
    if(isNaN(rand_idx)) return;
    if(rand_idx < 0 || 32767 <= rand_idx) return;
    simulate(rand_at(rand_idx));
  }

  function main() {
    const jobs = [];
    for(let i = 0; i < 3; ++i) {
      jobs.push(new Promise((resolve, reject) => {
        const img = new Image();
        img.addEventListener('load', () => {
          IMGS_CAPSULE_L[i] = img;
          resolve();
        });
        img.src = 'capsule-l-' + i + '.png';
      }));
      jobs.push(new Promise((resolve, reject) => {
        const img = new Image();
        img.addEventListener('load', () => {
          IMGS_CAPSULE_R[i] = img;
          resolve();
        });
        img.src = 'capsule-r-' + i + '.png';
      }));
      jobs.push(new Promise((resolve, reject) => {
        const img = new Image();
        img.addEventListener('load', () => {
          IMGS_VIRUS[i] = img;
          resolve();
        });
        img.src = 'virus-' + i + '.png';
      }));
    }

    Promise.all(jobs).then(() => {
      const elem = document.getElementById('rand_idx');
      elem.addEventListener('change', () => { update(elem); });
      update(elem);
    });
  }

  document.addEventListener('DOMContentLoaded', () => { main(); });
})();
