/**
 * api.js – Central API client + token management
 * All HTTP calls go through this file.
 */

const API_BASE = 'http://localhost:5000';

// ── Token Manager ─────────────────────────────────────────────────────────────
const tokenManager = {
  getAccessToken()  { return localStorage.getItem('accessToken'); },
  getRefreshToken() { return localStorage.getItem('refreshToken'); },

  setTokens(accessToken, refreshToken) {
    localStorage.setItem('accessToken', accessToken);
    if (refreshToken) localStorage.setItem('refreshToken', refreshToken);
  },

  clearTokens() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  },

  isAuthenticated() { return !!this.getAccessToken(); }
};

// ── Core Fetch Helper ─────────────────────────────────────────────────────────
const api = {
  async _request(method, path, body = null, retry = true) {
    const headers = { 'Content-Type': 'application/json' };
    const token = tokenManager.getAccessToken();
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const options = { method, headers };
    if (body) options.body = JSON.stringify(body);

    try {
      const res = await fetch(`${API_BASE}${path}`, options);
      const json = await res.json().catch(() => ({}));

      // Token expired → try silent refresh once
      if (res.status === 401 && json.message === 'Access token expired' && retry) {
        const refreshed = await this._silentRefresh();
        if (refreshed) return this._request(method, path, body, false);
        // If refresh fails, redirect to login
        tokenManager.clearTokens();
        window.location.href = '/login.html';
        return { data: null, error: 'Session expired. Please login again.' };
      }

      if (!res.ok) {
        const msg = json.message || `HTTP ${res.status}`;
        return { data: null, error: msg };
      }

      return { data: json, error: null };
    } catch (networkErr) {
      return { data: null, error: 'Cannot connect to server. Make sure the backend is running.' };
    }
  },

  async _silentRefresh() {
    const refreshToken = tokenManager.getRefreshToken();
    if (!refreshToken) return false;
    try {
      const res = await fetch(`${API_BASE}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken })
      });
      if (!res.ok) return false;
      const json = await res.json();
      tokenManager.setTokens(json.data.accessToken, null);
      return true;
    } catch { return false; }
  },

  get(path)          { return this._request('GET',    path); },
  post(path, body)   { return this._request('POST',   path, body); },
  put(path, body)    { return this._request('PUT',    path, body); },
  delete(path)       { return this._request('DELETE', path); }
};
