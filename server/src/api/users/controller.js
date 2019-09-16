const {
  create,
  allUsers,
  getById,
  updateById,
  deleteById,
  login
} = require("./service");

// routes

module.exports = {
  signup: async function(req, res, next) {
    try {
      const user = await create(req.body);
      if (user) {
        return res.json(user);
      }
      throw "Email or password is incorrect";
    } catch (error) {
      next(error);
    }
  },
  login: async function(req, res, next) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        throw "Missing email or password";
      }
      const user = await login({ email, password });
      if (user) {
        return res.json(user);
      }
      throw "Email or password is incorrect";
    } catch (error) {
      next(error);
    }
  },
  logout: async function(req, res, next) {
    try {
      //const user = await create(req.body);
    } catch (error) {
      next(error);
    }
  },
  me: async function(req, res, next) {
    try {
      const { id } = req.user;
      if (id) {
        const user = await getById(id);
        return res.json(user);
      }
    } catch (error) {
      next(error);
    }
  },
  getUsers: async function(req, res, next) {
    try {
      const users = await allUsers();
      return res.json(users);
    } catch (error) {
      next(error);
    }
  },
  createUser: async function(req, res, next) {
    try {
      const user = await create(req.body);
      return res.json(user);
    } catch (error) {
      next(error);
    }
  },
  getUser: async function(req, res, next) {
    try {
      const user = await getById(id);
      return res.json(user);
    } catch (error) {
      next(error);
    }
  },
  updateUser: async function(req, res, next) {
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
  },
  deleteUser: async function(req, res, next) {
    try {
      const user = await deleteById(req);
      return res.json(user);
    } catch (error) {
      next(error);
    }
  }
};
