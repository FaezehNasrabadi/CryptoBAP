import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Deployed to GitHub Pages at https://faezehnasrabadi.github.io/CryptoBAP/
export default defineConfig({
  site: 'https://faezehnasrabadi.github.io',
  base: '/CryptoBAP',
  trailingSlash: 'always',
  integrations: [
    sitemap({
      i18n: { defaultLocale: 'en', locales: { en: 'en-US', de: 'de-DE' } },
    }),
  ],
});
