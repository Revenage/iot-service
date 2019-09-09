function ErrorMiddleware(err, req, res, next) {
  if (typeof err === "string") {
    return res.status(400).json({ message: err });
  }

  switch (err.name) {
    case "UnauthorizedError":
      return res.status(401).json({ message: "Invalid Token" });

    default:
      const { errors } = err;
      if (errors) {
        return res
          .status(500)
          .json({ message: errors.map(({ message }) => message) });
      }

      return res.status(500).json({ message: err.message });
  }
}

module.exports = ErrorMiddleware;
