<script>
	import { base } from '$app/paths';
	import Background from '$lib/components/Background.svelte';
	import AssetFigure from '$lib/components/AssetFigure.svelte';
	import ProgressDots from '$lib/components/ProgressDots.svelte';
	import Stats from '$lib/components/Stats.svelte';
	import SupportButtons from '$lib/components/SupportButtons.svelte';
	import FeaturesCarousel from '$lib/components/FeaturesCarousel.svelte';
	import AwardsGrid from '$lib/components/AwardsGrid.svelte';
	import DownloadButtons from '$lib/components/DownloadButtons.svelte';
	import AboutDeveloper from '$lib/components/AboutDeveloper.svelte';
	
	const hero = `${base}/assets/im.webp`; // served from static/

	let active = $state(0);
	const total = 5;
	let isMobile = $state(false);
	let contentWrapper;
	let supportHighlighted = $state(false);

	function setActive(i) { 
		active = i; 
		// For mobile, scroll to the section
		if (isMobile && contentWrapper) {
			const section = contentWrapper.querySelector(`#section-${i}`);
			if (section) {
				section.scrollIntoView({ behavior: 'smooth' });
			}
		}
	}
	
	function handleSupportClick() {
		supportHighlighted = true;
		// Auto-remove highlight after 5 seconds
		setTimeout(() => {
			supportHighlighted = false;
		}, 5000);
	}

	// Check if we're on mobile
	function checkMobile() {
		isMobile = window.innerWidth <= 992;
	}

	let throttle = false;
	$effect(() => {
		// Initialize mobile check
		checkMobile();
		
		// Add resize listener
		const onResize = () => checkMobile();
		addEventListener('resize', onResize);

		// Desktop navigation events - only active when not mobile
		const onWheel = (e) => {
			if (isMobile || throttle) return; 
			throttle = true;
			let next = active;
			if (e.deltaY > 0) { if (next < total - 1) next++; }
			else { if (next > 0) next--; }
			if (next !== active) active = next;
			setTimeout(() => (throttle = false), 600);
		};

		let touchStartY = 0;
		let touchLastY = 0;
		const onTouchStart = (e) => { 
			if (isMobile) return; // Disable for mobile
			touchStartY = touchLastY = e.touches[0].clientY; 
		};
		const onTouchMove = (e) => { 
			if (isMobile) return; // Disable for mobile
			touchLastY = e.touches[0].clientY; 
		};
		const onTouchEnd = () => {
			if (isMobile) return; // Disable for mobile
			const dy = touchLastY - touchStartY;
			if (Math.abs(dy) < 35) return;
			let next = active;
			if (dy < 0) { if (next < total - 1) next++; } else { if (next > 0) next--; }
			if (next !== active) active = next;
		};

		// Mobile scroll listener - track which section is in view
		const onScroll = () => {
			if (!isMobile || !contentWrapper) return;
			
			const scrollTop = contentWrapper.scrollTop;
			const containerHeight = contentWrapper.clientHeight;
			const sections = contentWrapper.querySelectorAll('.content-section');
			
			let newActive = 0;
			sections.forEach((section, index) => {
				const rect = section.getBoundingClientRect();
				const containerRect = contentWrapper.getBoundingClientRect();
				const sectionTop = rect.top - containerRect.top + scrollTop;
				const sectionBottom = sectionTop + section.offsetHeight;
				
				// Check if section is mostly visible
				if (scrollTop >= sectionTop - containerHeight / 3 && scrollTop < sectionBottom - containerHeight / 3) {
					newActive = index;
				}
			});
			
			if (newActive !== active) {
				active = newActive;
			}
		};

		addEventListener('wheel', onWheel, { passive: true });
		addEventListener('touchstart', onTouchStart, { passive: true });
		addEventListener('touchmove', onTouchMove, { passive: true });
		addEventListener('touchend', onTouchEnd, { passive: true });
		
		return () => {
			removeEventListener('wheel', onWheel);
			removeEventListener('touchstart', onTouchStart);
			removeEventListener('touchmove', onTouchMove);
			removeEventListener('touchend', onTouchEnd);
			removeEventListener('resize', onResize);
		};
	});

	// Scroll listener for mobile
	$effect(() => {
		if (contentWrapper && isMobile) {
			const onScroll = () => {
				if (!isMobile) return;
				
				const scrollTop = contentWrapper.scrollTop;
				const containerHeight = contentWrapper.clientHeight;
				const sections = contentWrapper.querySelectorAll('.content-section');
				
				let newActive = 0;
				sections.forEach((section, index) => {
					const sectionTop = section.offsetTop;
					const sectionBottom = sectionTop + section.offsetHeight;
					
					// Check if section is mostly visible
					if (scrollTop >= sectionTop - containerHeight / 3 && scrollTop < sectionBottom - containerHeight / 3) {
						newActive = index;
					}
				});
				
				if (newActive !== active) {
					active = newActive;
				}
			};

			contentWrapper.addEventListener('scroll', onScroll, { passive: true });
			return () => {
				if (contentWrapper) {
					contentWrapper.removeEventListener('scroll', onScroll);
				}
			};
		}
	});
</script>

<svelte:head>
	<title>Bloomee</title>
</svelte:head>

<Background />
<AssetFigure src={hero} alt="Character listening to music" />

<div class="main-container" class:mobile={isMobile}>
	<ProgressDots count={total} index={active} onChange={setActive} />

	<div class="content-wrapper" bind:this={contentWrapper}>
		<section id="section-0" class="content-section {active === 0 ? 'active' : ''}" aria-hidden={active !== 0}>
			<h1 class="home-title">BloomeeTunes</h1>
			<p class="home-subtitle">Multi-source and open music app for free.</p>
			<div class="support-message" role="region" aria-label="Support Bloomee">
<span class="lead">Keep bloomee alive!</span>
<span class="msg">Your support today fuels every <span class="highlight">future update</span>, keeps Bloomee <span class="highlight">ad-free</span>, and ensures the tunes <span class="highlight">never stop</span>. ✨</span>
</div>


			
			<SupportButtons highlighted={supportHighlighted} />
			<Stats on:supportClick={handleSupportClick} />
		</section>
		<section id="section-1" class="content-section {active === 1 ? 'active' : ''}" aria-hidden={active !== 1}>
			<h2>SourceForge Awards</h2>
			<p class="section-subtitle">Proudly recognized by SourceForge community - achieved out of 500,000+ open source projects.</p>
			<AwardsGrid />
		</section>

		<section id="section-2" class="content-section {active === 2 ? 'active' : ''}" aria-hidden={active !== 1}>
			<!-- <h2>🌟 Why Choose Bloomee?</h2> -->
			<FeaturesCarousel />
		</section>


		<section id="section-3" class="content-section {active === 3 ? 'active' : ''}" aria-hidden={active !== 3}>
			<h2>Download Now</h2>
			<DownloadButtons />
		</section>

		<section id="section-4" class="content-section {active === 4 ? 'active' : ''}" aria-hidden={active !== 4}>
			<AboutDeveloper />
		</section>
	</div>
</div>

<style>
	/* Desktop Styles */
	.main-container { 
		display: flex; 
		height: 100vh; 
		width: 100vw; 
		position: relative; 
		z-index: 4; 
		overflow: hidden; 
	}
	
	.content-wrapper { 
		flex-grow: 1; 
		height: 100%; 
		position: relative; 
	}
	
	.content-section { 
		position: absolute; 
		inset: 0; 
		display: flex; 
		flex-direction: column; 
		justify-content: center; 
		padding-left: 5%; 
		padding-right: 55%; 
		opacity: 0; 
		transform: translateY(30px); 
		transition: opacity .45s ease, transform .45s ease; 
		pointer-events: none; 
	}
 
	.content-section h2 {
		font-size: 2.5rem;
		font-weight: 700;
		background: linear-gradient(45deg, #ff8a00, #e52e71);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		text-align: center;
		margin-bottom: 1.5rem; 
		letter-spacing: 1px; 
	}


	.content-section.active { 
		opacity: 1; 
		transform: translateY(0); 
		pointer-events: auto; 
	}
	
	.home-title { 
		font-family: 'Borel', sans-serif; 
		font-size: 4.5rem; 
		font-weight: 700; 
		font-style: italic; 
		margin-bottom: 0.2rem; 
		text-shadow: 0 0 15px rgba(200, 150, 255, 0.4); 
	}
	
	.home-subtitle {
		font-family: 'Borel', cursive;
		font-weight: 700;
		font-style: normal;
		font-size: 1.4rem;
		color: rgba(255, 237, 248, 0.949);
		margin-top: -0.8rem;
		margin-bottom: 0.8rem;
		max-width: 700px;
		letter-spacing: 0.3px;
background: linear-gradient(45deg, #ff5258, #ffd48e);
/* background: linear-gradient(45deg, #ff758c, #ff7eb3);  */
/* background: linear-gradient(45deg, #fbc2eb, #a6c1ee); Light pink to lavender */
/* background: linear-gradient(45deg, #ff6a88, #ff99ac); Coral pink to pastel pink */

		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		line-height: 1.2; /* Ensure enough vertical space */
		padding-top: 0.6rem; /* Add slight padding to prevent clipping */
	}
	
	h2 { 
		font-size: 2.5rem; 
		margin-bottom: 1.5rem; 
		letter-spacing: 1px; 
	}
	
	.section-subtitle { 
		font-family: 'Borel', cursive;
		font-weight: 700;
		font-style: normal;
		font-size: 1.4rem;
		color: rgba(255, 237, 248, 0.949);
		margin-top: 0.1rem;
		margin-bottom: 0.8rem;
		max-width: 700px;
		letter-spacing: 0.3px;
		line-height: 1.2; /* Ensure enough vertical space */
		padding-top: 0.6rem; /* Add slight padding to prevent clipping */
		text-align: center;
		margin-left: auto;
		margin-right: auto;
		background: linear-gradient(45deg, #ff5258, #ffd48e);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
	}

	.support-message {
		font-family: 'IBM Plex Sans', 'Montserrat', sans-serif;
		font-size: 1.1rem;
		font-weight: 500;
		color: rgb(255, 255, 255);
		margin-bottom: 1.8rem;
		max-width: 480px;
		line-height: 1.6;
		text-shadow: 0 2px 8px rgba(0, 0, 0, 0.645);
		padding: 1rem 1.2rem;
		background: rgba(255, 255, 255, 0.05);
		border-left: 3px solid rgb(235, 49, 111);
		border-radius: 8px;
		backdrop-filter: blur(10px);
	}

	.support-message .highlight {
		/* background: linear-gradient(45deg, #ff6a88, #ffb6c3); */
		/* -webkit-background-clip: text; */
		/* -webkit-text-fill-color: transparent; */
		color: #ff5258;
		font-weight: 700;
		text-shadow: none;
	}

	/* Keep titles and subtitles centered to the same width (desktop) */
	.content-section h2,
	.section-subtitle {
		max-width: 720px;
		margin-left: auto;
		margin-right: auto;
	}

	@media (max-width: 992px) {
		/* Match title/subtitle width on mobile as well */
		.content-section h2,
		.section-subtitle {
			max-width: 90%;
			margin-left: auto;
			margin-right: auto;
		}
	}

	/* Mobile Styles */
	@media (max-width: 992px) {
		.main-container { 
			flex-direction: column; 
			height: 100vh; 
			overflow: hidden;
		}
		
		.content-wrapper { 
			flex: 1; 
			overflow-y: auto; 
			padding-bottom: 70px; /* Space for progress dots */
			scroll-behavior: smooth;
			height: 100%;
		}
		
		.content-section { 
			position: relative; 
			padding: 20px 15px; 
			padding-top: 34px; /* push content slightly down on mobile so buttons sit nearer center */
			justify-content: flex-start; 
			background: rgba(16, 11, 33, 0.15); 
			backdrop-filter: blur(25px); 
			border-radius: 15px; 
			/* reduce horizontal margins and let sections size to their content on mobile */
			margin: 10px 12px; 
			min-height: auto; /* allow section height to fit content on small screens */
			transform: none;
			opacity: 1;
			pointer-events: auto;
			/* border: 1px solid rgba(255, 255, 255, 0.1); */
			/* All sections are visible in mobile, no absolute positioning */
			display: flex;
			flex-direction: column;
			justify-content: flex-start;
		}
		
		/* Remove transitions for mobile */
		.content-section {
			transition: none;
		}
		
		.home-title { 
			font-size: clamp(2.2rem, 8vw, 3rem); 
			line-height: 1.2;
			margin-bottom: 1rem;
			font-weight: 800;
		}

		.home-subtitle {
			font-size: clamp(0.8rem, 6vw, 1.2rem);
			line-height: 1.3;
			margin-bottom: 1rem;
			font-weight: 600;
		}
		
		.content-section h2 { 
			font-size: clamp(1.0rem, 7vw, 1.6rem); 
			margin-bottom: 1.2rem;
			line-height: 1.2;
			font-weight: 700;
		}
		
		.section-subtitle {
			font-weight: 700;
			font-style: normal;
			font-size: clamp(0.9rem, 4.5vw, 1.1rem);
			line-height: 1.4;
			margin-bottom: 1rem;
			color: rgba(255, 255, 255, 0.85);
			max-width: none;
			letter-spacing: 0.2px;
		}

		.support-message {
			font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
			font-size: clamp(0.85rem, 3.8vw, 1rem);
			font-weight: 400;
			line-height: 1.5;
			margin-bottom: 1.5rem;
			text-shadow: 0 2px 6px rgba(0, 0, 0, 0.5);
			color: rgba(255, 255, 255, 0.9);
			max-width: none;
			padding: 0.8rem 1rem;
			background: rgba(255, 255, 255, 0.08);
			border-radius: 6px;
			backdrop-filter: blur(8px);
		}

		.support-message .highlight {
			font-weight: 600;
		}
	}

</style>