function omitSensetive(data) {
  const { password, ...rest } = data;
  return rest;
}

module.exports = omitSensetive;
