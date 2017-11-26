import React, { Component } from 'react';

export default class QuestionNew extends Component {
  constructor(props) {
    super(props);
    this.onClickSubmit = this.onClickSubmit.bind(this);
    this.onChangeSubmit = this.onChangeSubmit.bind(this);

    var that = this;
    that.state = {
      user: null,
      comment: "",
      submitting: false,
      submitted: false,
      error_message: "",
    }
    fetch(process.env.REACT_APP_API_ENDPOINT + '/api/users/' + this.props.match.params.username)
      .then(function(response) { return response.json() })
      .then(function(data) {
        if (data.status === 'successful') {
          that.setState({
            user: data.user
          })
        }
      }).catch(function(response) {
        console.log("ERROR", response);
      });
  };
  onClickSubmit() {
    console.log("onClickSubmit. comment=%o", this.state.comment);
    var that = this;
    that.setState({submitting: true, error_message: ""});
    fetch(process.env.REACT_APP_API_ENDPOINT + '/api/questions/' + this.state.user.username, {
      method: 'POST',
      body: JSON.stringify({
        'comment': this.state.comment
      })
    }).then(function(response) { return response.json() })
      .then(function(data) {
        console.log(data);
        if (data.status === 'successful') {
          that.setState({ comment: "", submitting: false, submitted: true, error_message: "" });
        }
      }).catch(function(response) {
        console.log("ERROR", response);
        that.setState({ submitting: false, submitted: false, error_message: "Please try again" });
      });

  };
  onChangeSubmit(event) {
    console.log("onChangeSubmit. event=%o", event);
    this.setState({comment: event.target.value});
  };
  render() {
    if (this.state.submitted) {
      return (
        <div id="question-form">
          <p><img className="profile-image" src={this.state.user.profile_image} alt="profile"/></p>
          <p>{this.state.user.username}</p>
          <p>Thank you!!!</p>
        </div>
      );
    } else if (this.state.user) {
      var submit_button = (
        <p><button onClick={this.onClickSubmit}>Submit</button></p>
      );
      if (this.state.submitting) {
        submit_button = (
          <p>Please wait...</p>
        )
      }

      var error_message = null;
      if (this.state.error_message) {
        error_message = (
          <div>
            <p>{this.state.error_message}</p>
          </div>
        );
      }

      return (
        <div id="question-form">
          <p><img className="profile-image" src={this.state.user.profile_image} alt="profile"/></p>
          <p>{this.state.user.username}</p>
          <p><textarea value={this.state.comment} onChange={this.onChangeSubmit} placeholder="Please any comment(maximum 1000 characters)"></textarea></p>
          {submit_button}
          {error_message}
        </div>
      );
    } else {
      return null;
    }
  };
}
