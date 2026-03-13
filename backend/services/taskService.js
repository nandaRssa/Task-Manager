const TaskModel = require('../models/Task');

const getAllTasks = (userId) => {
  return TaskModel.findAllByUser(userId);
};

const getTaskById = (id, userId) => {
  const task = TaskModel.findByIdAndUser(id, userId);
  if (!task) {
    const error = new Error('Task not found');
    error.statusCode = 404;
    throw error;
  }
  return task;
};

const createTask = ({ title, description, status, userId }) => {
  return TaskModel.create({ title, description, status, userId });
};

const updateTask = (id, userId, data) => {
  // Ensure task belongs to user
  const existing = TaskModel.findByIdAndUser(id, userId);
  if (!existing) {
    const error = new Error('Task not found');
    error.statusCode = 404;
    throw error;
  }

  return TaskModel.update(id, userId, data);
};

const deleteTask = (id, userId) => {
  const deleted = TaskModel.delete(id, userId);
  if (!deleted) {
    const error = new Error('Task not found');
    error.statusCode = 404;
    throw error;
  }
};

module.exports = { getAllTasks, getTaskById, createTask, updateTask, deleteTask };
