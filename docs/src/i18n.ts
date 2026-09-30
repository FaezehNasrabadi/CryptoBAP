export type Lang = 'en' | 'de';
export type PageKey = 'home' | 'technical' | 'papers' | 'whatsapp' | 'demo';

/** Route table: path (relative to the site base) of each page per language. */
export const routes: Record<PageKey, Record<Lang, string>> = {
  home: { en: '', de: 'de/' },
  technical: { en: 'technical/', de: 'de/technik/' },
  papers: { en: 'papers/', de: 'de/publikationen/' },
  whatsapp: { en: 'whatsapp/', de: 'de/whatsapp/' },
  demo: { en: 'demo/', de: 'de/demo/' },
};
export const navOrder: PageKey[] = ['home', 'technical', 'papers', 'whatsapp', 'demo'];
export const langNames: Record<Lang, string> = { en: 'English', de: 'Deutsch' };

export const GITHUB = 'https://github.com/FaezehNasrabadi/CryptoBAP';

/** Prefix a site-relative path with the configured `base` (see astro.config.mjs). */
export const u = (path = '') => `${import.meta.env.BASE_URL.replace(/\/$/, '')}/${path}`;

export const t = {
  en: {
    tagline: 'Binary analysis for cryptographic protocols',
    menu: 'Menu',
    nav: {
      home: 'Overview',
      technical: 'How it works',
      papers: 'Publications',
      whatsapp: 'WhatsApp study',
      demo: 'Demo',
    },
    github: 'Source on GitHub',
    changeLang: 'Change language',
    theme: 'Switch colour theme',
    ftr: {
      blurb:
        'An automated toolchain for analysing cryptographic protocol implementations at the binary level, developed as academic research and released as open source.',
      researchBy: 'Research by',
      explore: 'Explore',
      research: 'Research',
      project: 'Project',
      artifact: 'Latest artifact',
      contact: 'Contact',
      base: '© 2026 CryptoBAP. Content licensed for academic use. Site built with Astro.',
    },
  },
  de: {
    tagline: 'Binäranalyse für kryptografische Protokolle',
    menu: 'Menü',
    nav: {
      home: 'Überblick',
      technical: 'Funktionsweise',
      papers: 'Publikationen',
      whatsapp: 'WhatsApp-Studie',
      demo: 'Demo',
    },
    github: 'Quellcode auf GitHub',
    changeLang: 'Sprache wechseln',
    theme: 'Farbschema wechseln',
    ftr: {
      blurb:
        'Eine automatisierte Werkzeugkette zur Analyse kryptografischer Protokollimplementierungen auf Binärebene — entwickelt in der akademischen Forschung und als Open Source veröffentlicht.',
      researchBy: 'Forschung von',
      explore: 'Entdecken',
      research: 'Forschung',
      project: 'Projekt',
      artifact: 'Aktuelles Artefakt',
      contact: 'Kontakt',
      base: '© 2026 CryptoBAP. Inhalte zur akademischen Nutzung lizenziert. Website mit Astro erstellt.',
    },
  },
} as const;
