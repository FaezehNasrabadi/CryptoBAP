import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Deployed to GitHub Pages at https://cryptobap.org
export default defineConfig({
  site: 'https://cryptobap.org',
  trailingSlash: 'always',
  integrations: [
    sitemap({
      i18n: { defaultLocale: 'en', locales: { en: 'en-US', de: 'de-DE' } },
    }),
  ],
});
