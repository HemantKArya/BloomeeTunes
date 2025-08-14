<script>
  export let count = 4;
  export let index = 0; // active index
  export let onChange = (i)=>{};

  function setActive(i) {
    if (i === index) return;
    onChange?.(i);
  }
</script>

<div class="progress-indicator">
  <div class="progress-dots" role="tablist" aria-label="Sections">
    {#each Array.from({ length: count }) as _, i}
      <button type="button" class="dot {i === index ? 'active' : ''}"
        role="tab" aria-selected={i === index} aria-controls={`section-${i}`}
        aria-label={`Go to section ${i + 1}`}
        on:click={() => setActive(i)}></button>
    {/each}
  </div>
</div>

<style>
  .progress-indicator { 
    width: 80px; 
    display: flex; 
    justify-content: center; 
    align-items: center; 
    z-index: 10; 
  }
  
  .progress-dots { 
    display: flex; 
    flex-direction: column; 
    gap: 20px; 
  }
  
  .dot { 
    width: 12px; 
    height: 12px; 
    background-color: rgba(255, 255, 255, 0.4); 
    border-radius: 50%; 
    transition: all 0.4s ease; 
    cursor: pointer; 
    border: 1px solid rgba(255, 255, 255, 0.2); 
    box-shadow: 0 0 5px rgba(255, 255, 255, 0.2);
  }
  
  .dot.active { 
    background-color: #ffffff; 
    transform: scale(1.8); 
    box-shadow: 0 0 15px rgba(255, 255, 255, 0.8), 0 0 25px rgba(255, 255, 255, 0.4); 
    border-color: rgba(255, 255, 255, 0.6);
  }

  @media (max-width: 992px) {
    .progress-indicator { 
      position: fixed;
      bottom: 15px;
      left: 50%;
      transform: translateX(-50%);
      width: auto; 
      height: auto;
      background: rgba(0, 0, 0, 0.6); 
      backdrop-filter: blur(15px);
      border-radius: 25px;
      padding: 10px 20px;
      border: 1px solid rgba(255, 255, 255, 0.2);
      z-index: 1000;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    }
    
    .progress-dots { 
      flex-direction: row; 
      gap: 15px;
    }
    
    .dot {
      width: 10px;
      height: 10px;
      background-color: rgba(255, 255, 255, 0.3);
      box-shadow: 0 0 3px rgba(255, 255, 255, 0.2);
    }
    
    .dot.active {
      transform: scale(1.5);
      background-color: #ffffff;
      box-shadow: 0 0 10px rgba(255, 255, 255, 0.8), 0 0 20px rgba(255, 255, 255, 0.4);
    }
  }
</style>
