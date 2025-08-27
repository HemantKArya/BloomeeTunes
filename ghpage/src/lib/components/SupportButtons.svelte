<script>
	export let buttons = [
		{ type: 'librepay', icon: 'fa-solid fa-heart', text: 'Liberapay', href: 'https://liberapay.com/hemantkarya' },
        { type: 'upi', text: 'Razorpay UPI', href: 'https://razorpay.me/@iamhemant', customIcon: 'https://upload.wikimedia.org/wikipedia/commons/e/e1/UPI-Logo-vector.svg' },
		{ type: 'paypal', icon: 'fa-brands fa-paypal', text: 'PayPal', href: 'https://paypal.me/iamhemantin' },
	];

	export let highlighted = false;
</script>

<div class="support-container" class:highlighted>
	<h3>Buy me a coffee 🍵</h3>
	<div class="support-buttons">
		{#each buttons as button}
			<a href={button.href} class="support-btn {button.type}" target="_blank" rel="noopener noreferrer">
				{#if button.customIcon}
					<img src={button.customIcon} alt="{button.text} icon" class="btn-icon">
				{:else}
					<i class="{button.icon} btn-icon"></i>
				{/if}
				<span class="btn-text">{button.text}</span>
			</a>
		{/each}
	</div>
</div>

<style>
	.support-container h3 { 
		font-size: 1.2rem;
		font-family: 'Borel', sans-serif; 
		font-weight: 500; 
		color: #ffffff; 
		margin-bottom: 1rem; 
	}
	
	.support-buttons { 
		display: flex; 
		gap: 0.8rem;
		flex-wrap: wrap;
	}
	
	.support-btn { 
		/* Use inline-flex for better alignment and wrapping */
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
		/* Normalize line-height to prevent text from adding extra vertical space */
		line-height: 1;
	}
	
	.support-btn:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
	}
	
	/* --- Main Fix: Unified Icon Styling for Perfect Alignment --- */
	.btn-icon {
		/* Set a fixed size for the icon container */
		width: 20px;
		height: 20px;
		/* Use flexbox to center the icon glyph/image within its own container */
		display: inline-flex;
		align-items: center;
		justify-content: center;
	}

	/* Ensure Font Awesome icons fit neatly inside their container */
	.btn-icon.fa-solid, .btn-icon.fa-brands {
		font-size: 18px; 
	}

	.btn-text {
		/* This class ensures the text is treated as a distinct element from the icon */
		display: inline-block;
	}
	
	/* --- Button Color Styles --- */
	.support-btn.paypal {
		background: #256aff; /* A more accurate PayPal blue */
		border: 1px solid rgba(95, 131, 238, 0.7);
		color: white;
	}
	
	.support-btn.upi {
		background: rgba(34, 139, 34, 0.9);
		border: 1px solid rgba(34, 139, 34, 0.7);
		color: white;
	}

	/* Style for the UPI icon image */
	.support-btn.upi .btn-icon {
		filter: brightness(0) invert(1);
	}
	
	.support-btn.librepay {
		background: #f6c915; /* Standard Librepay yellow */
		border: 1px solid rgba(255, 215, 0, 0.7);
		/* Use dark text for better contrast and readability */
		color: #1a1a1a; 
	}
	
	/* --- Highlighted State Styles (Unchanged) --- */
	.support-container.highlighted {
		animation: none;
	}
	
	.support-container.highlighted .support-btn.paypal {
		background: rgb(69, 112, 255);
		border-color: rgb(67, 146, 255);
		box-shadow: 
			0 3px 12px rgba(106, 168, 255, 0.4),
			0 0 20px rgba(101, 161, 245, 0.3);
		animation: softBlink 1s ease-in-out 3;
	}
	
	.support-container.highlighted .support-btn.upi {
		background: rgba(34, 139, 34, 1);
		border-color: rgba(34, 139, 34, 1);
		box-shadow: 
			0 3px 12px rgba(34, 139, 34, 0.4),
			0 0 20px rgba(34, 139, 34, 0.3);
		animation: softBlink 1s ease-in-out 3;
	}
	
	.support-container.highlighted .support-btn.librepay {
		background: rgba(255, 215, 0, 1);
		border-color: rgba(255, 215, 0, 1);
		box-shadow: 
			0 3px 12px rgba(255, 215, 0, 0.4),
			0 0 20px rgba(255, 215, 0, 0.3);
		animation: softBlink 1s ease-in-out 3;
	}
	
	.support-container.highlighted .support-btn:hover {
		transform: translateY(-2px);
	}
	
	.support-container.highlighted h3 {
		color: #ffffff;
		text-shadow: 0 0 8px rgba(255, 255, 255, 0.4);
	}
	
	@keyframes softBlink {
		0%, 100% { filter: brightness(1); transform: scale(1); }
		50% { filter: brightness(1.1); transform: scale(1.02); }
	}

	/* --- Responsive Styles (Unchanged) --- */
	@media (max-width: 992px) {
		.support-container { 
			margin-top: 1.5rem;
		}
		
		.support-container h3 {
			text-align: center;
			margin-bottom: 1rem;
		}
		
		.support-buttons { 
			flex-direction: column; 
			gap: 0.8rem; 
			align-items: stretch;
		}
		
		.support-btn { 
			padding: 0.6rem 1.2rem; 
			font-size: 0.85rem;
			text-align: center;
			border-radius: 8px;
		}
	}
</style>