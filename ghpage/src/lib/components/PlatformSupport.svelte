<script>
	export let platforms = [
		{ icon: 'fa-brands fa-windows', name: 'Windows' },
		{ icon: 'fa-brands fa-linux', name: 'Linux' },
		{ icon: 'fa-brands fa-android', name: 'Android' }
	];
</script>

<div class="platforms-container">
	{#each platforms as platform}
		<div class="platform-widget">
			<i class={platform.icon}></i>
			<span>{platform.name}</span>
		</div>
	{/each}
</div>

<style>
	.platforms-container { 
		display: flex; 
		gap: 1rem; 
		margin-bottom: 2.5rem; 
	}
	
	.platform-widget { 
		padding: 0.6rem 1rem; 
		background: rgba(255, 255, 255, 0.08); 
		border: 1px solid rgba(255, 255, 255, 0.15); 
		border-radius: 12px; 
		backdrop-filter: blur(12px); 
		display: flex; 
		flex-direction: row; 
		justify-content: center; 
		align-items: center; 
		gap: 8px; 
		transition: all .3s ease; 
		min-width: 100px;
		cursor: default;
		pointer-events: none;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	}
	
	.platform-widget:hover { 
		background: rgba(255, 255, 255, 0.12);
		border-color: rgba(255, 255, 255, 0.25); 
		box-shadow: 0 4px 12px rgba(255, 255, 255, 0.1);
		transform: translateY(-1px);
	}
	
	.platform-widget i { 
		font-size: 1.2rem; 
		color: #ffffff; 
		text-shadow: 0 0 8px rgba(255, 255, 255, 0.4);
	}
	
	.platform-widget span { 
		font-size: 0.85rem; 
		font-weight: 500; 
		color: #ffffff; 
		text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.6);
	}

	@media (max-width: 992px) {
		.platforms-container { 
			flex-wrap: wrap; 
			gap: 0.8rem; 
			margin-bottom: 1.5rem; 
			justify-content: center;
		}
		
		.platform-widget { 
			padding: 0.5rem 0.8rem;
			min-width: 85px;
		}
		
		.platform-widget i { 
			font-size: 1.1rem; 
		}
		
		.platform-widget span { 
			font-size: 0.75rem; 
		}
	}
</style>
