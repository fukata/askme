import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
  constructor(props) {
    super(props);
    var that = this;
    that.state = {
      config: {}
    };
    fetch(process.env.REACT_APP_API_ENDPOINT + '/api/config', {mode: 'cors', credentials: 'include'})
      .then(function(response) { return response.json() })
      .then(function(data) {
        that.setState({
          config: data.data
        });
      }).catch(function(response) {
        console.log("ERROR", response);
      });
  };
  render() {
    //FIXME ログインフォーム 別コンポーネント化した方が良い。
    var login_form = null;
    if (this.state.config && this.state.config.user) {
      login_form = (
        <p>Hello, {this.state.config.user.username}, <a href={process.env.REACT_APP_API_ENDPOINT + "/logout"}>Logout</a></p>
      );
    } else {
      login_form = (
        <p><a href={process.env.REACT_APP_API_ENDPOINT + "/auth/twitter"}>Login by Twitter</a></p>
      );
    };

    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        { login_form }
      </div>
    );
  }
}

export default App;
