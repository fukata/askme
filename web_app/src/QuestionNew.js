import React, { Component } from 'react';

export default class QuestionNew extends Component {
  constructor(props) {
    super(props);
    var that = this;
    that.state = {
      user: null
    }
    fetch(process.env.REACT_APP_API_ENDPOINT + '/api/users/' + this.props.match.params.username)
      .then(function(response) { return response.json() })
      .then(function(data) {
        that.setState({
          user: data.user
        })
      }).catch(function(response) {
        console.log("ERROR", response);
      });
  };
  render() {
    if (this.state.user) {
      return (
        <div id="question-form">
          <p><img className="profile-image" src={this.state.user.profile_image} alt="profile"/></p>
          <p>{this.state.user.username}</p>
          <p><textarea placeholder="Please any comment(maximum 1000 characters)" maxLength="1000"></textarea></p>
          <p><button>Submit</button></p>
        </div>
      );
    } else {
      return null;
    }
  };
}
