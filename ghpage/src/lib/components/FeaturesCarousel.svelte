<script>
	import { onMount, onDestroy } from 'svelte';

	// All features remain in a flat array
	const allFeatures = [
		{ icon: 'fa-solid fa-ban', title: 'Ad-Free Experience', desc: 'Say goodbye to interruptions' },
		{ icon: 'fa-solid fa-globe', title: 'Multi-Source Player', desc: 'YouTube, Jio Saavn & more' },
		{ icon: 'fa-solid fa-code', title: 'Flutter-Powered', desc: 'Beautiful design meets performance' },
		{ icon: 'fa-solid fa-music', title: 'Time-Synced Lyrics', desc: 'Sing along perfectly' },
		{ icon: 'fa-solid fa-download', title: 'Offline Playback', desc: 'Music anywhere, anytime' },
		{ icon: 'fa-solid fa-brain', title: 'AI Recommendations', desc: 'Discover new favorites' },
		{ icon: 'fa-solid fa-table-list', title: 'Playlist Import', desc: 'From various sources' },
		{ icon: 'fa-solid fa-moon', title: 'Sleep Timer', desc: 'Peaceful listening' },
		{ icon: 'fa-solid fa-chart-line', title: 'Global Charts', desc: 'Billboard, Last.fm & more' },
		{ icon: 'fa-solid fa-feather', title: 'Lightweight', desc: 'Minimal data & space usage' },
		{ icon: 'fa-solid fa-share', title: 'Playlist Sharing', desc: 'Share your music taste' },
		{ icon: 'fa-solid fa-language', title: 'Multi-Language', desc: 'Global accessibility' }
	];

	let carousel;
	let rotation = 0;
	let autoRotateInterval;
	const numItems = allFeatures.length;
	const rotationAngle = 360 / numItems;
	
	// --- Reactive and Responsive Properties ---
	let innerWidth = 0;
	let cardWidth = 220;
	let carouselRadius = 420;

	// This reactive block recalculates the radius based on screen size
	$: {
		if (innerWidth < 500) { // More aggressive mobile breakpoint
			cardWidth = 180;
		} else {
			cardWidth = 220;
		}
		
		// The formula for the radius needed to prevent overlap
		const gapFactor = 1.2; // Increase for more space between cards
		const angle = Math.PI / numItems;
		carouselRadius = (cardWidth / 2) * gapFactor / Math.tan(angle);
	}

	function startAutoRotate() {
		stopAutoRotate(); // Ensure no multiple intervals are running
		autoRotateInterval = setInterval(() => {
			rotation -= rotationAngle;
		}, 3000); // Rotate every 3 seconds
	}

	function stopAutoRotate() {
		clearInterval(autoRotateInterval);
	}

	function handleNext() {
		rotation -= rotationAngle;
		resetAutoRotate();
	}
	
	function handlePrev() {
		rotation += rotationAngle;
		resetAutoRotate();
	}

	// Reset the timer on manual navigation
	function resetAutoRotate() {
		stopAutoRotate();
		startAutoRotate();
	}

	onMount(() => {
		startAutoRotate();
	});

	onDestroy(() => {
		stopAutoRotate();
	});
</script>

<svelte:window bind:innerWidth />

<!-- 
  FIX: This wrapper is the key.
  It controls the max-width and clips any overflow,
  making the component a well-behaved citizen on the page.
-->
<div 
	class="features-wrapper" 
	aria-label="Features carousel"
	style="--radius: {carouselRadius}px; --card-width: {cardWidth}px;"
>
	<div class="features-container">
		<div 
			class="features-carousel" 
			bind:this={carousel}
			style="transform: translateZ(calc(var(--radius) * -1)) rotateY({rotation}deg);"
		>
			{#each allFeatures as feature, i}
				<div 
					class="feature-cell" 
					style="transform: rotateY({i * rotationAngle}deg) translateZ(var(--radius));"
				>
					<div class="feature-card">
						<i class="{feature.icon}" aria-hidden="true"></i>
						<span><b>{feature.title}</b><br>{feature.desc}</span>
					</div>
				</div>
			{/each}
		</div>
	</div>

	<div class="carousel-navigation">
		<button class="nav-arrow" on:click={handlePrev} aria-label="Previous feature">
			<i class="fa-solid fa-chevron-left"></i>
		</button>
		<button class="nav-arrow" on:click={handleNext} aria-label="Next feature">
			<i class="fa-solid fa-chevron-right"></i>
		</button>
	</div>
</div>

<style>
	/* 
	  The wrapper now controls the maximum size and crucially hides overflow.
	  This solves the horizontal scrollbar problem.
	*/
	.features-wrapper {
		width: 100%;
		max-width: 600px; /* Constrains the component on large screens */
		margin: 1rem auto; /* reduced vertical margin to avoid large gaps on mobile */
		padding: 0 1rem;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		align-items: center;
		overflow-x: hidden; /* This is the most important fix! */
	}

	/* 
	  The container's job is to set the 3D space.
	  It now fills its parent wrapper instead of having a fixed width.
	*/
	.features-container {
		width: 100%;
		height: 200px; /* adjusted height for better mobile experience */
		position: relative;
		perspective: 1000px;
		margin-bottom: 1rem; /* reduced margin to avoid large gaps on mobile */
	}

	.features-carousel {
		width: 100%;
		height: 100%;
		position: absolute;
		transform-style: preserve-3d;
		transition: transform 1s cubic-bezier(0.77, 0, 0.175, 1);
	}

	.feature-cell {
		position: absolute;
		left: calc(50% - (var(--card-width) / 2));
		top: 10px;
		width: var(--card-width);
		height: 180px;
		backface-visibility: hidden;
		-webkit-backface-visibility: hidden;
	}

	.feature-card {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		text-align: center;
		gap: 0.8rem;
		width: 100%;
			height: 160px; /* adjusted height for better mobile experience */
		padding: 1rem;
		border-radius: 15px;
		background: rgba(30, 30, 45, 0.4);
		border: 1px solid rgba(255, 255, 255, 0.15);
		backdrop-filter: blur(12px);
		box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
		color: #d1d1d1;
		font-size: 0.9rem;
		box-sizing: border-box;
	}
	
	.feature-card i { 
		font-size: 1.8rem; 
		background: linear-gradient(45deg, #ff8a00, #e52e71); 
		-webkit-background-clip: text; 
		background-clip: text; 
		color: transparent; 
	}

	.feature-card b {
		color: #ffffff;
		font-size: 1rem;
	}

	.carousel-navigation {
		display: flex;
		gap: 1.5rem;
	}

	.nav-arrow {
		background: rgba(255, 255, 255, 0.1);
		border: 1px solid rgba(255, 255, 255, 0.2);
		border-radius: 50%;
		width: 44px;
		height: 44px;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.3s ease;
		backdrop-filter: blur(10px);
		color: #ffffff;
	}

	.nav-arrow:hover {
		background: rgba(255, 255, 255, 0.2);
		transform: scale(1.05);
	}

	/* --- Responsive Adjustments --- */
	@media (max-width: 500px) {
			.features-container {
				height: 170px; /* slightly shorter on very small screens */
				perspective: 600px;
			}

		.feature-cell {
			height: 160px;
		}

		.feature-card {
			font-size: 0.85rem;
		}

		.feature-card b {
			font-size: 0.95rem;
		}
	}
</style>