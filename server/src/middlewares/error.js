function ErrorMiddleware(err, req, res, next) {
  if (typeof err === "string") {
    return res.status(400).json({ error: err });
  }

  switch (err.name) {
    case "UnauthorizedError":
      return res.status(401).json({ error: `Invalid Token: ${err.message}` });

    default:
      const { errors } = err;
      if (errors) {
        return res
          .status(500)
          .json({ error: errors.map(({ message }) => message) });
      }

      return res.status(500).json({ error: err.message });
  }
}

module.exports = ErrorMiddleware;
