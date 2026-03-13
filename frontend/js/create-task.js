/**
 * create-task.js – Handle task creation form
 */

const form       = document.getElementById('createTaskForm');
const alertBox   = document.getElementById('alertBox');
const alertMsg   = document.getElementById('alertMsg');
const submitBtn  = document.getElementById('submitBtn');
const btnText    = document.getElementById('btnText');
const btnSpinner = document.getElementById('btnSpinner');

function showError(msg) {
  alertMsg.textContent = msg;
  alertBox.classList.add('visible');
}

function setLoading(on) {
  submitBtn.disabled = on;
  btnText.textContent = on ? 'Creating…' : 'Create Task';
  btnSpinner.style.display = on ? 'inline-block' : 'none';
}

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  alertBox.classList.remove('visible');

  const title       = document.getElementById('title').value.trim();
  const description = document.getElementById('description').value.trim();
  const status      = document.getElementById('status').value;

  const titleError = document.getElementById('titleError');
  titleError.classList.remove('visible');

  if (!title) {
    titleError.textContent = 'Title is required';
    titleError.classList.add('visible');
    return;
  }

  setLoading(true);
  const { data, error } = await api.post('/tasks', { title, description, status });
  setLoading(false);

  if (error) return showError(error);

  // Success – go back to dashboard
  window.location.href = 'dashboard.html';
});
