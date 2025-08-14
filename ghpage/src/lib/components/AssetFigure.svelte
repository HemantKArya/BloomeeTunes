<script>
  export let src = '';
  export let alt = '';
</script>

<div class="asset-container" aria-hidden="true">
  <div class="asset-glow"></div>
  <img {src} {alt} class="asset-image" />
</div>

<style>
  .asset-container {
    position: fixed; top: 0; right: 0; width: 60%; height: 100%;
    pointer-events: none; display: flex; align-items: flex-end; justify-content: flex-end; z-index: 2;
  }
  .asset-glow { position: absolute; inset: 0; background: radial-gradient(circle at 50% 50%, rgba(45, 100, 240, 0.15), transparent 65%); z-index: 1; }
  .asset-image {
    position: absolute; bottom: 0; right: 0; z-index: 2;
    max-height: 100%; max-width: 100%; height: auto; width: auto;
  }

  @media (max-width: 992px) {
    .asset-container { 
      position: fixed;
      width: 100%; 
      height: 50%; /* Reduced height for mobile */
      top: auto; 
      bottom: 0; 
      z-index: 1;
      /* Ensure it doesn't interfere with scrolling */
      pointer-events: none;
    }
    .asset-image { 
      bottom: 0; 
      right: 0; 
      max-width: 80%; /* Reduced size for mobile */
      max-height: 100%; 
      /* Add some opacity to make it less prominent while scrolling */
      opacity: 0.8;
    }
    .asset-glow { display: none; }
  }
</style>
