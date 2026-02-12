/* ===== Base Path Detection =====
 * On gh-pages everything is flat at the root. During local dev the HTML
 * lives in site/ while assets (images, markdown, PDFs) are in the repo root.
 * We detect this by checking whether the page was served from a /site/ path.
 */
const BASE = (() => {
  const path = window.location.pathname;
  // If served from /site/ or /site/index.html, assets are one level up
  if (/\/docs(\/|\/index\.html)?$/i.test(path)) return '../';
  return '';
})();

/* ===== Document Registry ===== */
const DOCS = {
  core: {
    en: { md: 'lonelog.md', pdf: 'lonelog.pdf', epub: 'lonelog.epub', odt: 'lonelog.odt' },
    it: { md: 'lonelog-it.md', pdf: 'lonelog-it.pdf', epub: 'lonelog-it.epub', odt: 'lonelog-it.odt' },
    fr: { md: 'lonelog-fr.md', pdf: 'lonelog-fr.pdf', epub: 'lonelog-fr.epub', odt: 'lonelog-fr.odt' }
  },
  combat: {
    en: { md: 'lonelog-combat-module.md' }
  },
  dungeon: {
    en: { md: 'lonelog-dungeon-crawling-module.md' }
  },
  resource: {
    en: { md: 'lonelog-resource-tracking-module.md' }
  }
};

const DOC_LABELS = {
  core: 'Lonelog (Core)',
  combat: 'Combat Module',
  dungeon: 'Dungeon Crawling Module',
  resource: 'Resource Tracking Module'
};

const LANGS = ['en', 'it', 'fr'];

/* ===== State ===== */
let currentDoc = 'core';
let currentLang = 'en';

/* ===== DOM References ===== */
const $ = (sel) => document.querySelector(sel);
const sidebar = $('.sidebar');
const sidebarOverlay = $('.sidebar-overlay');
const tocList = $('#toc-list');
const docSelect = $('#doc-select');
const langButtons = document.querySelectorAll('.lang-btn');
const themeToggle = $('.theme-toggle');
const heroSection = $('.hero');
const articleEl = $('.article');
const heroTitle = $('#hero-title');
const heroSubtitle = $('#hero-subtitle');
const heroMeta = $('#hero-meta');
const downloadsEl = $('#downloads');

/* ===== Frontmatter Parser ===== */
function parseFrontmatter(text) {
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return { meta: {}, body: text };

  const meta = {};
  match[1].split(/\r?\n/).forEach(line => {
    const idx = line.indexOf(':');
    if (idx > 0) {
      const key = line.slice(0, idx).trim();
      let val = line.slice(idx + 1).trim();
      // Strip surrounding quotes
      if ((val.startsWith('"') && val.endsWith('"')) ||
          (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      meta[key] = val;
    }
  });

  const body = text.slice(match[0].length).trim();
  return { meta, body };
}

/* ===== Slug Generator ===== */
function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

/* ===== TOC Generator ===== */
let observer = null;

function buildTOC() {
  // Clean up previous observer
  if (observer) observer.disconnect();

  const headings = articleEl.querySelectorAll('h1, h2, h3, h4');
  tocList.innerHTML = '';

  if (headings.length === 0) return;

  const tocItems = [];

  headings.forEach((heading, i) => {
    const level = parseInt(heading.tagName[1]);
    // Map h1->h2 class, h2->h2, h3->h3, h4->h4 for TOC nesting
    const tocLevel = Math.max(2, level);
    const id = heading.id || `section-${slugify(heading.textContent)}-${i}`;
    heading.id = id;

    const li = document.createElement('li');
    li.className = `toc-h${tocLevel}`;
    const a = document.createElement('a');
    a.href = `#${id}`;
    a.textContent = heading.textContent;
    a.dataset.target = id;
    li.appendChild(a);
    tocList.appendChild(li);
    tocItems.push({ el: heading, link: a });
  });

  // Intersection Observer for active highlight
  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.id;
          tocList.querySelectorAll('a').forEach(a => a.classList.remove('active'));
          const active = tocList.querySelector(`a[data-target="${id}"]`);
          if (active) active.classList.add('active');
        }
      });
    },
    {
      rootMargin: `-${parseInt(getComputedStyle(document.documentElement).getPropertyValue('--header-height')) + 16}px 0px -60% 0px`,
      threshold: 0
    }
  );

  tocItems.forEach(item => observer.observe(item.el));

  // Smooth scroll on TOC click
  tocList.addEventListener('click', (e) => {
    if (e.target.tagName === 'A') {
      e.preventDefault();
      const targetId = e.target.dataset.target;
      const target = document.getElementById(targetId);
      if (target) {
        target.scrollIntoView({ behavior: 'smooth' });
        // Close sidebar on mobile
        if (window.innerWidth < 768) {
          sidebar.classList.remove('open');
          sidebarOverlay.classList.remove('visible');
        }
      }
    }
  });
}

/* ===== Document Loader ===== */
async function loadDocument(doc, lang) {
  const entry = DOCS[doc] && DOCS[doc][lang];
  if (!entry) return;

  // Show loading state
  articleEl.innerHTML = '<div class="loading">Loading...</div>';

  try {
    const response = await fetch(BASE + entry.md);
    if (!response.ok) throw new Error(`Failed to load ${entry.md}`);
    const text = await response.text();
    const { meta, body } = parseFrontmatter(text);

    // Render markdown
    articleEl.innerHTML = marked.parse(body);

    // Update hero
    updateHero(meta, doc, lang);

    // Update downloads
    updateDownloads(doc, lang);

    // Build TOC
    buildTOC();

    // Update state
    currentDoc = doc;
    currentLang = lang;
    updateHash();
    updateUI();

    // Scroll to top
    window.scrollTo({ top: 0 });

  } catch (err) {
    articleEl.innerHTML = `<div class="loading">Error loading document: ${err.message}</div>`;
  }
}

/* ===== Hero Update ===== */
function updateHero(meta, doc, lang) {
  heroTitle.textContent = meta.title || DOC_LABELS[doc];
  heroSubtitle.textContent = meta.subtitle || '';

  // Build meta info
  let metaHtml = '';
  if (meta.author) metaHtml += `<span>${meta.author}</span>`;
  if (meta.translator) metaHtml += `<span>Translated by ${meta.translator}</span>`;
  if (meta.version) metaHtml += `<span class="badge">v${meta.version}</span>`;
  if (meta.status) metaHtml += `<span class="badge">${meta.status}</span>`;
  if (meta.license) metaHtml += `<span>${meta.license}</span>`;
  heroMeta.innerHTML = metaHtml;
}

/* ===== Downloads Update ===== */
function updateDownloads(doc, lang) {
  const entry = DOCS[doc] && DOCS[doc][lang];
  if (!entry) {
    downloadsEl.innerHTML = '';
    return;
  }

  const isCore = doc === 'core';
  let html = '';

  if (isCore) {
    html += `<a href="${BASE + entry.pdf}" class="download-btn primary" download>PDF</a>`;
    html += `<a href="${BASE + entry.epub}" class="download-btn secondary" download>EPUB</a>`;
    html += `<a href="${BASE + entry.odt}" class="download-btn secondary" download>ODT</a>`;
    html += `<a href="${BASE + entry.md}" class="download-btn secondary" download>Markdown</a>`;
  } else {
    html += `<a href="${BASE + entry.md}" class="download-btn primary" download>Markdown</a>`;
  }

  downloadsEl.innerHTML = html;
}

/* ===== UI State Update ===== */
function updateUI() {
  const isModule = currentDoc !== 'core';

  // Document select
  docSelect.value = currentDoc;

  // Language buttons
  langButtons.forEach(btn => {
    const lang = btn.dataset.lang;
    btn.classList.toggle('active', lang === currentLang);
    btn.disabled = isModule && lang !== 'en';
  });
}

/* ===== URL Hash ===== */
function updateHash() {
  const hash = `#lang=${currentLang}&doc=${currentDoc}`;
  history.replaceState(null, '', hash);
}

function parseHash() {
  const hash = location.hash.slice(1);
  const params = new URLSearchParams(hash);
  const lang = params.get('lang');
  const doc = params.get('doc');

  if (lang && LANGS.includes(lang)) currentLang = lang;
  if (doc && DOCS[doc]) currentDoc = doc;

  // Modules are English-only
  if (currentDoc !== 'core') currentLang = 'en';
}

/* ===== Theme ===== */
function initTheme() {
  const saved = localStorage.getItem('lonelog-theme');
  if (saved === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark');
    themeToggle.textContent = '\u2600\uFE0F';
  } else {
    document.documentElement.setAttribute('data-theme', 'light');
    themeToggle.textContent = '\uD83C\uDF19';
  }
}

function toggleTheme() {
  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  if (isDark) {
    document.documentElement.setAttribute('data-theme', 'light');
    localStorage.setItem('lonelog-theme', 'light');
    themeToggle.textContent = '\uD83C\uDF19';
  } else {
    document.documentElement.setAttribute('data-theme', 'dark');
    localStorage.setItem('lonelog-theme', 'dark');
    themeToggle.textContent = '\u2600\uFE0F';
  }
}

/* ===== Sidebar Toggle ===== */
function toggleSidebar() {
  if (window.innerWidth < 768) {
    sidebar.classList.toggle('open');
    sidebarOverlay.classList.toggle('visible');
  } else {
    sidebar.classList.toggle('collapsed');
  }
}

/* ===== Event Listeners ===== */
function init() {
  // Theme
  initTheme();
  themeToggle.addEventListener('click', toggleTheme);

  // Sidebar toggle
  $('.sidebar-toggle').addEventListener('click', toggleSidebar);
  sidebarOverlay.addEventListener('click', () => {
    sidebar.classList.remove('open');
    sidebarOverlay.classList.remove('visible');
  });

  // Document select
  docSelect.addEventListener('change', (e) => {
    const doc = e.target.value;
    let lang = currentLang;
    // Modules are English-only
    if (doc !== 'core') lang = 'en';
    loadDocument(doc, lang);
  });

  // Language buttons
  langButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      if (btn.disabled) return;
      const lang = btn.dataset.lang;
      loadDocument(currentDoc, lang);
    });
  });

  // Hash change
  window.addEventListener('hashchange', () => {
    parseHash();
    loadDocument(currentDoc, currentLang);
  });

  // Populate doc select
  Object.entries(DOC_LABELS).forEach(([key, label]) => {
    const opt = document.createElement('option');
    opt.value = key;
    opt.textContent = label;
    docSelect.appendChild(opt);
  });

  // Resolve asset paths (images live in repo root, not in site/)
  document.querySelectorAll('[data-asset]').forEach(el => {
    el.src = BASE + el.dataset.asset;
  });

  // Parse initial state from hash
  parseHash();

  // Load initial document
  loadDocument(currentDoc, currentLang);
}

// Start
document.addEventListener('DOMContentLoaded', init);
