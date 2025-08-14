import adapter from '@sveltejs/adapter-static';


/** @type {import('@sveltejs/kit').Config} */
const dev = process.env.NODE_ENV === 'development';
const config = {
  kit: {
    adapter: adapter({
      // SPA fallback for GitHub Pages
      fallback: 'index.html',
    }),
    // Use base only in production (GitHub Pages), not during local dev
    paths: {
      base: dev ? '' : '/BloomeeTunes',
    },
    prerender: {
      entries: ['*'], // prerender all routes
      handleHttpError: 'warn'
    }
  }
};

export default config;
