const jwt = require('jsonwebtoken');
const UserModel = require('../models/User');

const authenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token is required'
    });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const user = UserModel.findById(payload.userId);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    req.user = user;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Access token expired'
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Invalid access token'
    });
  }
};

module.exports = { authenticate };
