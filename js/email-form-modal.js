/**
 * Email Form Modal — Formspree Integration
 *
 * Displays a modal with contact form when user clicks "Orçamento" button
 * Submits to Formspree without page reload
 *
 * Setup:
 * 1. Create Formspree account at https://formspree.io
 * 2. Create new form, get FORM_ID (e.g., "mjvdydoj")
 * 3. Replace FORMSPREE_FORM_ID below with actual ID
 * 4. Include this script in <head> of all pages
 */

const FORMSPREE_FORM_ID = 'mvzyvapj'; // Catálogo 3D quote form
const FORMSPREE_ENDPOINT = `https://formspree.io/f/${FORMSPREE_FORM_ID}`;

/**
 * Initialize email modal (call once on DOMContentLoaded)
 */
function initEmailModal() {
  // Create modal HTML
  const modalHTML = `
    <div id="emailModal" class="modal" style="display: none;">
      <div class="modal-content">
        <span class="close-modal">&times;</span>
        <h2>Solicitar Orçamento</h2>
        <form id="emailForm" method="POST">
          <input type="hidden" name="_subject" value="Novo Orçamento — Catálogo JFA">
          <input type="hidden" name="_captcha" value="false">

          <div class="form-group">
            <label for="email">Email *</label>
            <input type="email" id="email" name="email" required placeholder="seu@email.com">
          </div>

          <div class="form-group">
            <label for="nome">Nome *</label>
            <input type="text" id="nome" name="nome" required placeholder="Seu Nome Completo">
          </div>

          <div class="form-group">
            <label for="categoria">Categoria *</label>
            <select id="categoria" name="categoria" required>
              <option value="">-- Seleccione --</option>
              <option value="automatismos">Automatismos</option>
              <option value="controlo-acesso">Controlo Acesso</option>
              <option value="cortinados">Cortinados</option>
              <option value="estores">Estores</option>
              <option value="fenolicos">Fenólicos</option>
              <option value="logos">Logos</option>
              <option value="mobiliario">Mobiliário</option>
              <option value="pergola">Pérgola</option>
              <option value="portas">Portas</option>
              <option value="prot-solar">Protecção Solar</option>
              <option value="redes-mosquiteiras">Redes Mosquiteiras</option>
              <option value="tapetes">Tapetes</option>
            </select>
          </div>

          <div class="form-group">
            <label for="produto">Produto (opcional)</label>
            <input type="text" id="produto" name="produto" placeholder="Nome do produto ou referência">
          </div>

          <div class="form-group">
            <label for="mensagem">Mensagem *</label>
            <textarea id="mensagem" name="mensagem" required rows="4" placeholder="Descreva seu interesse ou pergunta..."></textarea>
          </div>

          <div class="form-group">
            <label for="telefone">Telefone (opcional)</label>
            <input type="tel" id="telefone" name="telefone" placeholder="+351 912 345 678">
          </div>

          <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px;">Enviar Orçamento</button>
          <div id="formMessage" style="margin-top: 10px; text-align: center; display: none;"></div>
        </form>
      </div>
    </div>
  `;

  // Inject modal HTML
  document.body.insertAdjacentHTML('beforeend', modalHTML);

  // Get modal elements
  const modal = document.getElementById('emailModal');
  const closeBtn = document.querySelector('.close-modal');
  const emailForm = document.getElementById('emailForm');
  const formMessage = document.getElementById('formMessage');

  // Close modal on X click
  closeBtn.addEventListener('click', () => {
    modal.style.display = 'none';
  });

  // Close modal on outside click
  window.addEventListener('click', (e) => {
    if (e.target === modal) {
      modal.style.display = 'none';
    }
  });

  // Handle form submission
  emailForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const formData = new FormData(emailForm);
    const submitBtn = emailForm.querySelector('button[type="submit"]');
    const originalButtonText = submitBtn.textContent;

    try {
      // Show loading state
      submitBtn.disabled = true;
      submitBtn.textContent = 'Enviando...';
      formMessage.style.display = 'none';

      // Submit to Formspree
      const response = await fetch(FORMSPREE_ENDPOINT, {
        method: 'POST',
        headers: {
          'Accept': 'application/json'
        },
        body: formData
      });

      if (response.ok) {
        // Success
        formMessage.style.display = 'block';
        formMessage.style.color = '#4caf50';
        formMessage.textContent = '✓ Orçamento enviado com sucesso! Responderemos em breve.';

        // Track conversion
        if (window.Analytics && window.Analytics.trackConversion) {
          const categoria = formData.get('categoria');
          const produto = formData.get('produto') || 'N/A';
          window.Analytics.trackConversion(categoria, produto);
        }

        // Save to localStorage for follow-up
        const submissionData = {
          timestamp: new Date().toISOString(),
          email: formData.get('email'),
          categoria: formData.get('categoria'),
          produto: formData.get('produto')
        };
        const submissions = JSON.parse(localStorage.getItem('quoteSubmissions') || '[]');
        submissions.push(submissionData);
        localStorage.setItem('quoteSubmissions', JSON.stringify(submissions));

        // Clear form and close modal after 2s
        setTimeout(() => {
          emailForm.reset();
          modal.style.display = 'none';
          formMessage.style.display = 'none';
        }, 2000);
      } else {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
    } catch (error) {
      // Error
      formMessage.style.display = 'block';
      formMessage.style.color = '#f44336';
      formMessage.textContent = `✗ Erro ao enviar: ${error.message}`;

      if (window.Analytics && window.Analytics.trackError) {
        window.Analytics.trackError('Form submission failed', { error: error.message });
      }
    } finally {
      // Restore button
      submitBtn.disabled = false;
      submitBtn.textContent = originalButtonText;
    }
  });

  // Attach open modal function to window
  window.openEmailModal = (productName = '', category = '') => {
    if (productName) document.getElementById('produto').value = productName;
    if (category) document.getElementById('categoria').value = category;
    modal.style.display = 'block';
    document.getElementById('email').focus();
  };

  console.log('[EmailModal] Initialized and ready');
}

// Initialize on DOM load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initEmailModal);
} else {
  initEmailModal();
}
