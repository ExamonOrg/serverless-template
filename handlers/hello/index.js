module.exports.handler = async (event, context) => {
  try {
    const response = {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Hello, Bekir'
      })
    };
    return response;
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Internal server error'
      })
    };
  }
};
