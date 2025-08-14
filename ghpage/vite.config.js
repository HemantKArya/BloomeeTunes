import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

const dev = process.env.NODE_ENV === 'development';

export default defineConfig({
	plugins: [tailwindcss(), sveltekit()],
	base: dev ? '/' : '/BloomeeTunes/',
	build: {
		outDir: 'build', // Ensure this matches your output directory
	},
});
