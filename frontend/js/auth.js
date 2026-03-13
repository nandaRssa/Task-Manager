/**
 * auth.js – Shared auth utilities for all protected pages.
 * Import this after api.js on every page that needs authentication.
 */

// Guard: redirect to login if not authenticated
function requireAuth() {
  if (!tokenManager.isAuthenticated()) {
    window.location.href = '/login.html';
    return false;
  }
  return true;
}

// Load current user and populate topbar
async function loadCurrentUser() {
  const { data, error } = await api.get('/auth/me');
  if (error || !data) return;

  const user = data.data.user;
  const nameEl    = document.getElementById('userName');
  const initialEl = document.getElementById('userInitial');
  if (nameEl)    nameEl.textContent    = user.name;
  if (initialEl) initialEl.textContent = user.name.charAt(0).toUpperCase();
}

// Logout handler
function setupLogoutBtn() {
  const btn = document.getElementById('logoutBtn');
  if (!btn) return;
  btn.addEventListener('click', async () => {
    const refreshToken = tokenManager.getRefreshToken();
    await api.post('/auth/logout', { refreshToken });
    tokenManager.clearTokens();
    window.location.href = '/login.html';
  });
}

// Auto-run on every app page
(function init() {
  // Only guard on app pages (not auth pages)
  const authPages = ['login.html', 'register.html'];
  const isAuthPage = authPages.some(p => window.location.pathname.endsWith(p));
  if (!isAuthPage) {
    if (!requireAuth()) return;
    loadCurrentUser();
    setupLogoutBtn();
  }
})();
