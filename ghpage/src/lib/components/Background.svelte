<div class="background-container"></div>
<canvas id="particle-canvas"></canvas>

<script>
  // particle effect from landing page
  let canvasEl;
  let ctx;
  let particles = [];

  class Particle {
    constructor(x, y, s, c, sx, sy) {
      this.x = x;
      this.y = y;
      this.size = s;
      this.color = c;
      this.speedX = sx;
      this.speedY = sy;
      this.maxLife = Math.random() * 300 + 150;
      this.life = this.maxLife;
      this.hasGlow = Math.random() > 0.6; // Reduce glow probability
      this.blinks = Math.random() > 0.7;
      this.blinkPhase = Math.random() * Math.PI * 2;
      this.isDreamy = false; // Disable dreamy blur for all particles
      this.extraShiny = false; // Disable extra shiny particles
    }

    update() {
      this.life -= 1;
      if (this.life > 0) {
        this.x += this.speedX + (Math.random() - 0.5) * 0.05; // Add slight randomness to movement
        this.y += this.speedY + (Math.random() - 0.5) * 0.05;
      }
    }

    draw() {
      ctx.save();
      ctx.beginPath();
      let a = this.life / this.maxLife;
      if (this.blinks) {
        const b = (Math.sin(this.life * 0.03 + this.blinkPhase) + 1) / 2;
        a *= b;
      }
      ctx.globalAlpha = Math.max(0, a);

      if (this.hasGlow) {
        ctx.shadowBlur = this.size * 3; // Reduce glow intensity
        ctx.shadowColor = this.color;
      }

      ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
      ctx.fillStyle = this.color;
      ctx.fill();
      ctx.restore();
    }
  }

  function createParticle() {
    const s = Math.random() * 1.5 + 0.5,
      x = Math.random() * canvasEl.width * 0.6 + canvasEl.width * 0.4, // Shift particles to the right
      y = Math.random() * canvasEl.height,
      c = `hsl(${Math.random() * 50 + 250}, 100%, ${Math.random() * 20 + 60}%)`, // Adjust brightness for variety
      sx = (Math.random() - 0.5) * 0.1,
      sy = (Math.random() - 0.5) * 0.1;
    particles.push(new Particle(x, y, s, c, sx, sy));
  }

  function init() {
    particles = [];
    const n = (canvasEl.width * canvasEl.height) / 20000; // Reduce particle density
    for (let i = 0; i < n; i++) createParticle();
  }

  function animate() {
    ctx.clearRect(0, 0, canvasEl.width, canvasEl.height);
    for (let i = particles.length - 1; i >= 0; i--) {
      const p = particles[i]; p.update(); p.draw(); if (p.life <= 0) { particles.splice(i, 1); createParticle(); }
    }
    requestAnimationFrame(animate);
  }

  $effect(()=>{
    canvasEl = document.getElementById('particle-canvas');
    if (!canvasEl) return;
    ctx = canvasEl.getContext('2d');
    const setSize = () => { canvasEl.width = innerWidth; canvasEl.height = innerHeight; init(); };
    setSize();
    addEventListener('resize', setSize);
    animate();
    return () => removeEventListener('resize', setSize);
  });
</script>

<style>
  .background-container { position: fixed; inset: 0; background: radial-gradient(circle at 70% 50%, var(--bg-color-mid), var(--bg-color-deep) 60%); }
  #particle-canvas { position: fixed; inset: 0; pointer-events: none; z-index: 3; }
</style>
