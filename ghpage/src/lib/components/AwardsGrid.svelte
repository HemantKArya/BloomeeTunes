<script>
	import { onMount, onDestroy } from 'svelte';

	const projectUrl = 'https://sourceforge.net/projects/bloomee/';
	const sfId = '3775631';

	const badges = [
		{ badge: 'oss-open-source-excellence-black', metadata: 'achievement=oss-open-source-excellence' },
		{ badge: 'oss-community-leader-black', metadata: 'achievement=oss-community-leader' },
		{ badge: 'oss-users-love-us-black' },
		{ badge: 'oss-community-choice-black', metadata: 'achievement=oss-community-choice' },
		{ badge: 'oss-rising-star-black', metadata: 'achievement=oss-rising-star' },
		{ badge: 'oss-sf-favorite-black', metadata: 'achievement=oss-sf-favorite' },
	];

	let carousel;
	let rotation = 0;
	let autoRotateInterval;
	
	const numItems = badges.length;
	const rotationAngle = 360 / numItems;

	// --- Multi-Tier Responsive Properties ---
	let innerWidth = 0;
	let cardWidth = 190;
	let carouselRadius = 288;
	
	$: {
		// Three tiers of responsiveness for better adaptability
		if (innerWidth > 992) { 		// Large Desktop
			cardWidth = 210;
		} else if (innerWidth > 600) {  // Tablet / Small Desktop
			cardWidth = 190;
		} else { 						// Mobile
			cardWidth = 150;
		}
		
		// Recalculate radius automatically based on the chosen card width
		const angle = Math.PI / numItems;
		const gapFactor = 1.35; // Fine-tuned for good spacing at all sizes
		carouselRadius = (cardWidth / 2) * gapFactor / Math.tan(angle);
	}

	$: currentBadgeIndex = (Math.round((-rotation % 360) / rotationAngle) + numItems) % numItems;

	onMount(() => {
		const src = `https://b.sf-syn.com/badge_js?sf_id=${sfId}`;
		const sc = document.createElement('script');
		sc.async = true;
		sc.src = src;
		const p = document.getElementsByTagName('script')[0] || document.body.firstChild;
		p?.parentNode?.insertBefore(sc, p);

		autoRotateInterval = setInterval(() => {
			rotation -= rotationAngle;
		}, 3000);
	});

	onDestroy(() => {
		clearInterval(autoRotateInterval);
	});
</script>

<svelte:window bind:innerWidth />

<!-- This wrapper is now more robust at containing the animation -->
<div 
	class="awards-wrapper" 
	aria-label="SourceForge awards carousel"
	style="--radius: {carouselRadius}px; --card-width: {cardWidth}px;"
>
	<div class="awards-container">
		<div 
			class="carousel" 
			bind:this={carousel} 
			style="transform: translateZ(calc(var(--radius) * -1)) rotateY({rotation}deg);"
		>
			{#each badges as b, i}
				<div 
					class="carousel-item"
					class:active={i === currentBadgeIndex}
					style="transform: rotateY({i * rotationAngle}deg) translateZ(var(--radius));"
				>
					<div
						class="sf-root"
						data-id={sfId}
						data-badge={b.badge}
						data-metadata={b.metadata}
						style="width: 130px;"
					>
						<a href={projectUrl} target="_blank" rel="noopener noreferrer">BloomeeTunes</a>
					</div>
				</div>
			{/each}
		</div>
	</div>
</div>

<style>
	.awards-wrapper {
		width: 100%;
		/* Set a max-width for very large screens to keep it elegant */
		max-width: 500px; 
		/* reduce vertical margin so stacked sections are closer on mobile */
		margin: 1rem auto;
		padding: 0.5rem 0; /* smaller vertical padding */
		
		/* --- Scrollbar Fix --- */
		/* Flexbox helps create a reliable container */
		display: flex;
		justify-content: center;
		/* These two properties are key to preventing scrollbars */
		position: relative;
		overflow: hidden; 
	}

	.awards-container {
		width: 100%;
		height: 200px; /* slightly reduced to tighten vertical rhythm */
		position: relative;
		perspective: 1200px; /* Default perspective for large screens */
	}

	.carousel {
		width: 100%;
		height: 100%;
		position: absolute;
		transform-style: preserve-3d;
		transition: transform 1.2s cubic-bezier(0.77, 0, 0.175, 1);
	}

	.carousel-item {
		position: absolute;
		left: calc(50% - var(--card-width) / 2);
		top: 10px;
		width: var(--card-width);
		height: 180px;
		
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 0.8rem;
		border-radius: 12px;
		box-sizing: border-box;
		
		background: rgba(30, 30, 45, 0.5);
		border: 1px solid rgba(255, 255, 255, 0.15);
		backdrop-filter: blur(10px);
		
		transition: transform 0.8s ease, opacity 0.8s ease;
		
		opacity: 0.5;
		transform-origin: center center;
	}

	.carousel-item.active {
		opacity: 1;
		transform: scale(1.1); /* Active item is larger */
		border-color: rgba(255, 255, 255, 0.3);
	}

	.carousel-item .sf-root {
		display: flex;
		align-items: center;
		justify-content: center;
	}

	/* --- Responsive Adjustments --- */
	@media (max-width: 992px) {
		.awards-wrapper {
			max-width: 400px;
		}
		.awards-container {
			height: 190px;
		}
	}
	
	@media (max-width: 600px) {
		.awards-wrapper {
			max-width: 320px;
		}
		.awards-container {
			height: 160px; /* reduce for small phones */
			perspective: 800px; /* Reduce perspective depth on mobile */
		}
		.carousel-item {
			height: 130px;
			top: 12px;
		}
	}
</style>