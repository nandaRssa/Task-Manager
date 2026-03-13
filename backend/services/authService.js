const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const UserModel = require('../models/User');
const RefreshTokenModel = require('../models/RefreshToken');

const generateAccessToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' }
  );
};

const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );
};

const register = async ({ name, email, password }) => {
  // Check if email already exists
  const existing = UserModel.findByEmail(email);
  if (existing) {
    const error = new Error('Email already registered');
    error.statusCode = 409;
    throw error;
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 12);

  // Create user
  const user = UserModel.create({ name, email, password: hashedPassword });
  return user;
};

const login = async ({ email, password }) => {
  // Find user
  const user = UserModel.findByEmail(email);
  if (!user) {
    const error = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  // Verify password
  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    const error = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  // Generate tokens
  const accessToken = generateAccessToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  // Save refresh token to DB (expires in 7 days)
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
  RefreshTokenModel.create(user.id, refreshToken, expiresAt);

  const { password: _, ...safeUser } = user;
  return { user: safeUser, accessToken, refreshToken };
};

const refresh = (refreshToken) => {
  if (!refreshToken) {
    const error = new Error('Refresh token is required');
    error.statusCode = 400;
    throw error;
  }

  // Verify token in DB
  const tokenRecord = RefreshTokenModel.findByToken(refreshToken);
  if (!tokenRecord) {
    const error = new Error('Invalid or expired refresh token');
    error.statusCode = 401;
    throw error;
  }

  // Verify JWT signature
  let payload;
  try {
    payload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  } catch {
    RefreshTokenModel.deleteByToken(refreshToken);
    const error = new Error('Invalid or expired refresh token');
    error.statusCode = 401;
    throw error;
  }

  // Issue new access token
  const newAccessToken = generateAccessToken(payload.userId);
  return { accessToken: newAccessToken };
};

const logout = (refreshToken) => {
  if (refreshToken) {
    RefreshTokenModel.deleteByToken(refreshToken);
  }
};

module.exports = { register, login, refresh, logout };
