<script>
	import { createEventDispatcher } from 'svelte';
	
	const dispatch = createEventDispatcher();
	
	function handleSupportClick() {
		dispatch('supportClick');
	}
	
	function handleGithubClick() {
		window.open('https://github.com/HemantKArya/BloomeeTunes', '_blank');
	}
</script>

<!-- <div class="stats-container"> -->
	<!-- Support Us Button -->
	<!-- <button class="support-btn" on:click={handleSupportClick}>
		<i class="fa-solid fa-hand-holding-dollar support-icon"></i>
		<span class="support-text">Support Us</span>
	</button> -->
	
	<!-- GitHub Button -->
	<!-- <button class="github-btn" on:click={handleGithubClick}>
		<i class="fa-brands fa-github github-icon"></i>
		<span class="github-text">GitHub</span>
	</button> -->
<!-- </div> -->

<style>
	.stats-container { 
		display: flex; 
		gap: 1rem; /* slightly larger gap between buttons */
		margin-top: 1.8rem; /* space from elements above */
		margin-bottom: 1.8rem; 
		justify-content: left; /* center horizontally */
		align-items: left; /* center vertically */
		width: 100%;
	}
	
	/* Support Button Styles */
	.support-btn {
		padding: 0.5rem 0.8rem;
		background: rgba(255, 255, 255, 0.1);
		border: 1.5px solid rgba(255, 255, 255, 0.3);
		border-radius: 30px;
		backdrop-filter: blur(12px);
		display: flex;
		flex-direction: row;
		justify-content: center;
		align-items: center;
		gap: 6px;
		transition: all 0.3s ease;
		position: relative;
		overflow: hidden;
		min-width: 90px;
		height: 38px;
		cursor: pointer;
		font-family: inherit;
		box-shadow: 
			0 2px 6px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.1);
	}
	
	.support-btn:hover {
		border-color: rgba(255, 255, 255, 0.5);
		background: rgba(255, 255, 255, 0.15);
		box-shadow: 
			0 3px 10px rgba(255, 255, 255, 0.2),
			0 0 12px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.15);
		transform: translateY(-1px);
	}
	
	.support-btn:active {
		transform: translateY(0);
		box-shadow: 
			0 2px 6px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.1);
	}
	
	.support-icon {
		font-size: 1rem;
		color: #ffffff;
		text-shadow: 0 0 6px rgba(255, 255, 255, 0.5);
		transition: all 0.3s ease;
	}
	
	.support-btn:hover .support-icon {
		text-shadow: 0 0 12px rgba(255, 255, 255, 0.8);
		filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.6));
	}
	
	.support-text {
		font-size: 0.8rem;
		font-weight: 600;
		color: #ffffff;
		text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.7);
	}

	/* GitHub Button Styles */
	.github-btn {
		padding: 0.5rem 0.8rem;
		background: rgba(255, 255, 255, 0.1);
		border: 1.5px solid rgba(255, 255, 255, 0.3);
		border-radius: 30px;
		backdrop-filter: blur(12px);
		display: flex;
		flex-direction: row;
		justify-content: center;
		align-items: center;
		gap: 6px;
		transition: all 0.3s ease;
		position: relative;
		overflow: hidden;
		min-width: 90px;
		height: 38px;
		cursor: pointer;
		font-family: inherit;
		box-shadow: 
			0 2px 6px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.1);
	}
	
	.github-btn:hover {
		border-color: rgba(255, 255, 255, 0.5);
		background: rgba(255, 255, 255, 0.15);
		box-shadow: 
			0 3px 10px rgba(255, 255, 255, 0.2),
			0 0 12px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.15);
		transform: translateY(-1px);
	}
	
	.github-btn:active {
		transform: translateY(0);
		box-shadow: 
			0 2px 6px rgba(255, 255, 255, 0.1),
			inset 0 1px 0 rgba(255, 255, 255, 0.1);
	}
	
	.github-icon {
		font-size: 1rem;
		color: #ffffff;
		text-shadow: 0 0 6px rgba(255, 255, 255, 0.5);
		transition: all 0.3s ease;
	}
	
	.github-btn:hover .github-icon {
		text-shadow: 0 0 12px rgba(255, 255, 255, 0.8);
		filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.6));
	}
	
	.github-text {
		font-size: 0.8rem;
		font-weight: 600;
		color: #ffffff;
		text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.7);
	}
	@media (max-width: 992px) {
		.stats-container {
			justify-content: center;
			flex-wrap: wrap;
			gap: 0.9rem;
			padding-top: 0.6rem; /* small extra space on mobile */
		}
		
		.support-btn, .github-btn {
			min-width: 85px;
			padding: 0.4rem 0.6rem;
			height: 34px;
		}

		.support-icon, .github-icon {
			font-size: 0.9rem;
		}
		
		.support-text, .github-text {
			font-size: 0.75rem;
		}
	}
</style>
