// Confetti system

const COLORS = ["#ff595e", "#ffca3a", "#6a4c93", "#1982c4", "#8ac926", "#ff924c"];
const PARTICLE_COUNT = 120;

/**
 * Launch a confetti burst on the screen.
 */
export function launchConfetti() {
  const canvas = document.createElement("canvas");
  canvas.style.cssText =
    "position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:9999;";
  document.body.appendChild(canvas);

  const ctx = canvas.getContext("2d");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const particles = Array.from({ length: PARTICLE_COUNT }, () => ({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height - canvas.height,
    w: Math.random() * 10 + 5,
    h: Math.random() * 6 + 4,
    color: COLORS[Math.floor(Math.random() * COLORS.length)],
    vx: Math.random() * 4 - 2,
    vy: Math.random() * 3 + 2,
    angle: Math.random() * Math.PI * 2,
    spin: Math.random() * 0.2 - 0.1,
  }));

  let animId;
  let elapsed = 0;

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => {
      p.x += p.vx;
      p.y += p.vy;
      p.angle += p.spin;
      ctx.save();
      ctx.translate(p.x, p.y);
      ctx.rotate(p.angle);
      ctx.fillStyle = p.color;
      ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
      ctx.restore();
    });

    elapsed++;
    if (elapsed < 180) {
      animId = requestAnimationFrame(draw);
    } else {
      cancelAnimationFrame(animId);
      canvas.remove();
    }
  }

  draw();
}
