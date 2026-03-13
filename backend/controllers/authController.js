const authService = require('../services/authService');

const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    const user = await authService.register({ name, email, password });
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: { user }
    });
  } catch (err) {
    next(err);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const { user, accessToken, refreshToken } = await authService.login({ email, password });
    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: { user, accessToken, refreshToken }
    });
  } catch (err) {
    next(err);
  }
};

const refresh = (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    const { accessToken } = authService.refresh(refreshToken);
    res.status(200).json({
      success: true,
      message: 'Token refreshed successfully',
      data: { accessToken }
    });
  } catch (err) {
    next(err);
  }
};

const logout = (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    authService.logout(refreshToken);
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (err) {
    next(err);
  }
};

const getMe = (req, res) => {
  res.status(200).json({
    success: true,
    data: { user: req.user }
  });
};

module.exports = { register, login, refresh, logout, getMe };
