<!-- No script needed: component is static and self-contained -->

<section class="about-developer">
  <h2>Who Am I?</h2>
  <p class="about-subtitle">
    Hi, I'm Hemant—a developer who codes for fun and shares open-source projects to learn, grow, and help others discover new possibilities.
  </p>
  <div class="contact-buttons">
  <a href="https://x.com/iamhemantindia" class="contact-btn x" target="_blank" rel="noopener noreferrer" aria-label="Hemant on X" title="X - iamhemantindia">
      <i class="fa-brands fa-x-twitter"></i>
      X
    </a>
  <a href="https://linkedin.com/in/iamhemantindia" class="contact-btn linkedin" target="_blank" rel="noopener noreferrer" aria-label="Hemant on LinkedIn" title="LinkedIn - iamhemantindia">
      <i class="fa-brands fa-linkedin"></i>
      LinkedIn
    </a>
  <a href="https://github.com/HemantKArya" class="contact-btn github" target="_blank" rel="noopener noreferrer" aria-label="Hemant on GitHub" title="GitHub - HemantKArya">
      <i class="fa-brands fa-github"></i>
      GitHub
    </a>
  <a href="https://instagram.com/iamhemantindia" class="contact-btn instagram" target="_blank" rel="noopener noreferrer" aria-label="Hemant on Instagram" title="Instagram - iamhemantindia">
      <i class="fa-brands fa-instagram"></i>
      Instagram
    </a>
  <a href="mailto:iamhemantindia@protonmail.com" class="contact-btn email" aria-label="Email Hemant" title="Email Hemant">
      <i class="fa-solid fa-envelope"></i>
      Email Me
    </a>
</section>

<style>
  .about-developer {
    text-align: center;
    /* Reduce top padding so title sits closer to the section top */
    padding: 0.6rem 1rem;
    background: transparent;
    color: rgba(255, 255, 255, 0.95);
    /* remove internal backdrop and corner radius to avoid double-panel look */
    backdrop-filter: none;
    border-radius: 0;
    margin: 6px 10px;
  }

  .about-developer h2 {
    font-size: 2.5rem;
    font-weight: 700;
    background: linear-gradient(45deg, #ff8a00, #e52e71);
  background-clip: text;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  margin-top: 0.2rem;
  margin-bottom: 0.6rem;
  }

  .about-subtitle {
    font-family: 'IBM Plex Sans', sans-serif;
    font-weight: 500;
    font-style: normal;
    font-size: 1.2rem;
    color: rgba(255, 237, 248, 0.949);
    margin-top: 0.1rem;
    margin-bottom: 1.5rem;
    max-width: 700px;
    letter-spacing: 0.3px;
    line-height: 1.2;
    padding-top: 0.6rem;
    text-align: center;
    margin-left: auto;
    margin-right: auto;
    background: linear-gradient(45deg, #ff5258, #ffd48e);
  background-clip: text;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .contact-buttons {
    display: flex;
    justify-content: center;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .contact-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.6rem;
    padding: 0.7rem 1.4rem;
    border-radius: 12px;
    text-decoration: none;
    font-weight: 500;
    font-size: 0.9rem;
    transition: all 0.3s ease;
    position: relative;
    backdrop-filter: blur(10px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    line-height: 1;
    color: white;
  }

  .contact-btn i {
    font-size: 1.2rem;
  }

  .contact-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(255, 255, 255, 0.4);
  }

  .contact-btn.email {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
  }

  .contact-btn.instagram {
    background: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888);
    border: 1px solid rgba(255, 255, 255, 0.3);
  }

  .contact-btn.linkedin {
    background: #0077b5;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }

  .contact-btn.github {
    background: #333;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }

  .contact-btn.x {
    background: #000;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }

  @keyframes softBlink {
    0%, 100% { filter: brightness(1); transform: scale(1); }
    50% { filter: brightness(1.1); transform: scale(1.02); }
  }

  .contact-btn:hover {
    animation: softBlink 1s ease-in-out 3;
  }

  @media (max-width: 768px) {
    .about-developer {
      padding: 0.8rem 0.8rem;
    }

    .about-developer h2 {
      font-size: 2rem;
    }

    .about-subtitle {
      font-size: 0.9rem;
    }

    .contact-btn {
      padding: 0.6rem 1rem;
      font-size: 0.85rem;
    }
  }
</style>
