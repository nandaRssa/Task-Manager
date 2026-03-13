/**
 * edit-task.js – Load task and handle update form
 */

const urlParams  = new URLSearchParams(window.location.search);
const taskId     = urlParams.get('id');

const form        = document.getElementById('editTaskForm');
const alertBox    = document.getElementById('alertBox');
const alertMsg    = document.getElementById('alertMsg');
const successBox  = document.getElementById('successBox');
const successMsg  = document.getElementById('successMsg');
const submitBtn   = document.getElementById('submitBtn');
const btnText     = document.getElementById('btnText');
const btnSpinner  = document.getElementById('btnSpinner');
const loadingCard = document.getElementById('loadingCard');
const formWrapper = document.getElementById('formWrapper');

if (!taskId) {
  window.location.href = 'dashboard.html';
}

function showError(msg) {
  successBox.classList.remove('visible');
  alertMsg.textContent = msg;
  alertBox.classList.add('visible');
}

function showSuccess(msg) {
  alertBox.classList.remove('visible');
  successMsg.textContent = msg;
  successBox.classList.add('visible');
}

function setLoading(on) {
  submitBtn.disabled = on;
  btnText.textContent = on ? 'Saving…' : 'Save Changes';
  btnSpinner.style.display = on ? 'inline-block' : 'none';
}

// Load existing task data
async function loadTask() {
  const { data, error } = await api.get(`/tasks/${taskId}`);

  loadingCard.style.display = 'none';
  formWrapper.style.display = 'block';

  if (error) {
    showError(error);
    form.style.display = 'none';
    return;
  }

  const task = data.data.task;
  document.getElementById('title').value       = task.title;
  document.getElementById('description').value = task.description || '';
  document.getElementById('status').value      = task.status;
}

// Submit update
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  alertBox.classList.remove('visible');
  successBox.classList.remove('visible');

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
  const { data, error } = await api.put(`/tasks/${taskId}`, { title, description, status });
  setLoading(false);

  if (error) return showError(error);

  showSuccess('Task updated successfully!');

  // Redirect to dashboard after 1.2s
  setTimeout(() => { window.location.href = 'dashboard.html'; }, 1200);
});

loadTask();
