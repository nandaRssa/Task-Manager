/**
 * dashboard.js – Task list with stats and filtering
 */

let allTasks = [];

async function loadTasks() {
  const tableBody = document.getElementById('tableBody');

  const { data, error } = await api.get('/tasks');

  if (error) {
    tableBody.innerHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">⚠️</div>
        <div class="empty-state-title">Failed to load tasks</div>
        <div class="empty-state-desc">${error}</div>
      </div>`;
    return;
  }

  allTasks = data.data.tasks;
  updateStats(allTasks);
  renderTable(allTasks);
}

function updateStats(tasks) {
  document.getElementById('statTotal').textContent     = tasks.length;
  document.getElementById('statPending').textContent   = tasks.filter(t => t.status === 'pending').length;
  document.getElementById('statInProgress').textContent = tasks.filter(t => t.status === 'in_progress').length;
  document.getElementById('statCompleted').textContent  = tasks.filter(t => t.status === 'completed').length;
}

function badgeHTML(status) {
  const labels = { pending: '⏳ Pending', in_progress: '🔄 In Progress', completed: '✅ Completed' };
  return `<span class="badge badge-${status}">${labels[status] || status}</span>`;
}

function formatDate(iso) {
  if (!iso) return '–';
  return new Date(iso).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

function renderTable(tasks) {
  const tableBody = document.getElementById('tableBody');

  if (tasks.length === 0) {
    tableBody.innerHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">📋</div>
        <div class="empty-state-title">No tasks found</div>
        <div class="empty-state-desc">Create your first task to get started.</div>
        <a href="create-task.html" class="btn btn-primary">+ New Task</a>
      </div>`;
    return;
  }

  const rows = tasks.map(task => `
    <tr>
      <td class="td-title">${escapeHtml(task.title)}</td>
      <td><span class="td-desc">${task.description ? escapeHtml(task.description) : '<span style="color:var(--text-muted)">No description</span>'}</span></td>
      <td>${badgeHTML(task.status)}</td>
      <td style="color:var(--text-muted);font-size:13px">${formatDate(task.created_at)}</td>
      <td class="td-actions">
        <a href="edit-task.html?id=${task.id}" class="btn btn-secondary btn-sm">✏ Edit</a>
        <button class="btn btn-danger btn-sm" onclick="deleteTask('${task.id}')">🗑 Delete</button>
      </td>
    </tr>
  `).join('');

  tableBody.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Title</th>
          <th>Description</th>
          <th>Status</th>
          <th>Created</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>`;
}

async function deleteTask(id) {
  if (!confirm('Are you sure you want to delete this task?')) return;
  const { error } = await api.delete(`/tasks/${id}`);
  if (error) { alert('Error: ' + error); return; }
  allTasks = allTasks.filter(t => t.id !== id);
  updateStats(allTasks);
  applyFilter();
}

function applyFilter() {
  const status = document.getElementById('filterStatus').value;
  const filtered = status ? allTasks.filter(t => t.status === status) : allTasks;
  renderTable(filtered);
}

function escapeHtml(str) {
  const d = document.createElement('div');
  d.appendChild(document.createTextNode(str));
  return d.innerHTML;
}

// Init
document.getElementById('filterStatus').addEventListener('change', applyFilter);
loadTasks();
