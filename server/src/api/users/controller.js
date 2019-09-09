const {
  create,
  allUsers,
  getById,
  updateById,
  deleteById
} = require("./service");

// routes

async function signup(req, res, next) {
  try {
    const user = await create(req.body);
    if (user) {
      return res.json(user);
    }
    throw "Email or password is incorrect";
  } catch (error) {
    next(error);
  }
}

async function login(req, res, next) {
  try {
    const user = await create(req.body);
  } catch (error) {
    next(error);
  }
}
async function logout(req, res, next) {
  try {
    const user = await create(req.body);
  } catch (error) {
    next(error);
  }
}
async function me(req, res, next) {
  try {
    const { id } = req.user;
    console.log("id", id);
    if (id) {
      const user = await getById(id);
      console.log("meuser", user);
      return res.json(user);
    }
  } catch (error) {
    next(error);
  }
}
async function getUsers(req, res, next) {
  try {
    const users = await allUsers();
    return res.json(users);
  } catch (error) {
    next(error);
  }
}
async function createUser(req, res, next) {
  try {
    const user = await create(req.body);
    return res.json(user);
  } catch (error) {
    next(error);
  }
}
async function getUser(req, res, next) {
  try {
    const user = await getById(id);
    return res.json(user);
  } catch (error) {
    next(error);
  }
}
async function updateUser(req, res, next) {
  try {
    const {
      body,
      params: { id }
    } = req;
    const user = await updateById({ body, id });
    return res.json(user);
  } catch (error) {
    next(error);
  }
}
async function deleteUser(req, res, next) {
  try {
    const user = await deleteById(req);
    return res.json(user);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  signup,
  login,
  logout,
  me,
  getUsers,
  createUser,
  getUser,
  updateUser,
  deleteUser
};
