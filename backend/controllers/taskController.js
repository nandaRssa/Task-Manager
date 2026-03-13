const taskService = require('../services/taskService');

const getAllTasks = (req, res, next) => {
  try {
    const tasks = taskService.getAllTasks(req.user.id);
    res.status(200).json({
      success: true,
      data: { tasks, count: tasks.length }
    });
  } catch (err) {
    next(err);
  }
};

const getTaskById = (req, res, next) => {
  try {
    const task = taskService.getTaskById(req.params.id, req.user.id);
    res.status(200).json({
      success: true,
      data: { task }
    });
  } catch (err) {
    next(err);
  }
};

const createTask = (req, res, next) => {
  try {
    const { title, description, status } = req.body;
    const task = taskService.createTask({
      title,
      description,
      status,
      userId: req.user.id
    });
    res.status(201).json({
      success: true,
      message: 'Task created successfully',
      data: { task }
    });
  } catch (err) {
    next(err);
  }
};

const updateTask = (req, res, next) => {
  try {
    const { title, description, status } = req.body;
    const task = taskService.updateTask(req.params.id, req.user.id, {
      title,
      description,
      status
    });
    res.status(200).json({
      success: true,
      message: 'Task updated successfully',
      data: { task }
    });
  } catch (err) {
    next(err);
  }
};

const deleteTask = (req, res, next) => {
  try {
    taskService.deleteTask(req.params.id, req.user.id);
    res.status(200).json({
      success: true,
      message: 'Task deleted successfully'
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllTasks, getTaskById, createTask, updateTask, deleteTask };
