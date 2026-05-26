document.addEventListener('DOMContentLoaded', function() {
  // Lazy-load images via IntersectionObserver
  const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = new Image();
        img.src = entry.target.dataset.src;
        img.onload = () => {
          entry.target.style.backgroundImage = `url('${entry.target.dataset.src}')`;
          entry.target.classList.remove('loading');
        };
        observer.unobserve(entry.target);
      }
    });
  }, { rootMargin: '50px' });

  document.querySelectorAll('.product-image[data-src]').forEach(el => {
    imageObserver.observe(el);
  });

  // Search/filter products
  const searchInput = document.getElementById('searchInput');
  if (searchInput) {
    searchInput.addEventListener('input', filterProducts);
  }

  function filterProducts() {
    const query = (searchInput.value || '').toLowerCase();
    const cards = document.querySelectorAll('.product-card');
    let visibleCount = 0;

    cards.forEach(card => {
      const name = (card.querySelector('.product-name')?.textContent || '').toLowerCase();
      const meta = (card.querySelector('.product-meta')?.textContent || '').toLowerCase();

      const matches = name.includes(query) || meta.includes(query);
      card.style.display = matches ? '' : 'none';

      if (matches) visibleCount++;
    });

    const resultCount = document.getElementById('resultCount');
    if (resultCount) resultCount.textContent = visibleCount;
  }

  // Attach "Orçamento" button handlers
  document.querySelectorAll('.btn-secondary').forEach(btn => {
    if (btn.textContent.trim() === 'Orçamento') {
      btn.addEventListener('click', (e) => {
        e.preventDefault();

        // Extract product name from card
        const card = btn.closest('.product-card');
        const productName = card?.querySelector('.product-name')?.textContent || '';

        // Extract category from page title or breadcrumb
        const categoryTitle = document.querySelector('h1')?.textContent || '';
        const categoryMatch = categoryTitle.match(/(\d+)\s*-\s*(.+)/);
        const category = categoryMatch ? categoryMatch[2].trim().toLowerCase() : '';

        // Open modal
        if (window.openEmailModal) {
          window.openEmailModal(productName, category);
        } else {
          console.warn('[App] openEmailModal not available - email-form-modal.js may not be loaded');
        }
      });
    }
  });
});
