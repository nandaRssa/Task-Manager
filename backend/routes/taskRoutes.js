const { Router } = require('express');
const { body } = require('express-validator');
const taskController = require('../controllers/taskController');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validate');

const router = Router();

// All task routes require authentication
router.use(authenticate);

const VALID_STATUSES = ['pending', 'in_progress', 'completed'];

// GET /tasks
router.get('/', taskController.getAllTasks);

// GET /tasks/:id
router.get('/:id', taskController.getTaskById);

// POST /tasks
router.post(
  '/',
  [
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('description').optional().isString().withMessage('Description must be a string'),
    body('status')
      .optional()
      .isIn(VALID_STATUSES)
      .withMessage(`Status must be one of: ${VALID_STATUSES.join(', ')}`)
  ],
  validate,
  taskController.createTask
);

// PUT /tasks/:id
router.put(
  '/:id',
  [
    body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
    body('description').optional().isString().withMessage('Description must be a string'),
    body('status')
      .optional()
      .isIn(VALID_STATUSES)
      .withMessage(`Status must be one of: ${VALID_STATUSES.join(', ')}`)
  ],
  validate,
  taskController.updateTask
);

// DELETE /tasks/:id
router.delete('/:id', taskController.deleteTask);

module.exports = router;
