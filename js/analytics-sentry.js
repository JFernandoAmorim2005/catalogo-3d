/**
 * Analytics Setup: Plausible + Sentry
 *
 * Plausible: Privacy-first analytics (no cookies)
 * Sentry: Error tracking + conversion events
 *
 * Insert in <head> of all pages:
 * <script defer data-domain="catalogo-3d.pages.dev" src="https://plausible.io/js/script.js"></script>
 * <script src="js/analytics-sentry.js"></script>
 */

// Sentry initialization (replace with actual DSN from https://sentry.io/settings/account/projects/)
// TODO: Criar conta em https://sentry.io e substitua por valor real
const SENTRY_DSN = 'https://REPLACE_WITH_REAL_DSN@o0000.ingest.sentry.io/0000000';

// Initialize Sentry (if DSN is configured)
if (SENTRY_DSN && !SENTRY_DSN.includes('REPLACE_WITH')) {
  Sentry.init({
    dsn: SENTRY_DSN,
    environment: 'production',
    tracesSampleRate: 0.1, // 10% of transactions
    beforeSend(event, hint) {
      // Filter out specific errors if needed
      return event;
    }
  });
  console.log('[Sentry] Initialized with DSN:', SENTRY_DSN.split('@')[0] + '@...');
}

/**
 * Track conversion: User clicked "Orçamento" (Request Quote)
 * Called when quote request button is clicked
 */
function trackConversion(category, productName) {
  // Plausible event (automatic via data-domain script)
  if (window.plausible) {
    window.plausible('Orçamento Solicitado', {
      props: {
        categoria: category,
        produto: productName
      }
    });
  }

  // Sentry event
  if (window.Sentry) {
    Sentry.captureMessage('Orçamento Solicitado', 'info', {
      tags: {
        categoria: category,
        evento: 'quote_request'
      },
      extra: {
        produto: productName,
        timestamp: new Date().toISOString()
      }
    });
  }

  console.log('[Analytics] Conversão rastreada:', { category, productName });
}

/**
 * Track category view
 */
function trackCategoryView(categoryName) {
  if (window.plausible) {
    window.plausible('Visualizar Categoria', {
      props: {
        categoria: categoryName
      }
    });
  }

  console.log('[Analytics] Categoria visualizada:', categoryName);
}

/**
 * Track search query
 */
function trackSearch(query, resultsCount) {
  if (window.plausible) {
    window.plausible('Pesquisa', {
      props: {
        termo: query,
        resultados: resultsCount
      }
    });
  }

  console.log('[Analytics] Pesquisa rastreada:', { query, resultsCount });
}

/**
 * Track error for debugging
 */
function trackError(errorMessage, context = {}) {
  if (window.Sentry) {
    Sentry.captureException(new Error(errorMessage), {
      tags: {
        categoria: 'user_error'
      },
      extra: context
    });
  }

  console.error('[Analytics] Erro rastreado:', { errorMessage, context });
}

// Export for use in other scripts
window.Analytics = {
  trackConversion,
  trackCategoryView,
  trackSearch,
  trackError
};

console.log('[Analytics] Sentry + Plausible initialized');
