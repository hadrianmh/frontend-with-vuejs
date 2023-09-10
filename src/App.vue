<template>
    <div id="app">
      <div class="wrap">
        <form v-if="!token">
          <div class="container">
            <label for="Email"><b>Email</b></label>
            <input type="text" placeholder="Enter email@gmail.com" id="email" required v-model="email">
            <label for="password"><b>Password</b></label>
            <input type="password" placeholder="Enter Password" id="password" required v-model="password">
            <label>
              <a id="showpassword" style="font-size:12px;" @click.prevent="showpass">Show Password?</a>
            </label>
            <button type="button" id="login" @click.prevent="login">Login</button>
          </div>
        </form>

        <div class="dashboard" v-if="token">
          <div class="btn-dashboard">
            <div class="btn-create">
              <button type="button" @click.prevent="showTodo">CREATE TODO</button>
            </div>
            <div class="btn-logout">
              <button type="button" @click.prevent="logout">LOGOUT</button>
            </div>
          </div>
          <div class="table" style="overflow-x:auto;">
            <table>
              <tr>
                <th>Title</th>
                <th>Description</th>
                <th>Created</th>
                <th>Option</th>
              </tr>
              <tr v-if="datas.length === 0">
                <td colspan="4" id="dataload"></td>
              </tr>
              <tr id="datatable" v-else v-for="data in datas" :key="data.uuid">
                <td>{{ data.title }}</td>
                <td>{{ data.description }}</td>
                <td>{{ data.created_at }}</td>
                <td>
                  <button type="button" id="getTodo" @click.prevent="getTodo(data.uuid)">Update</button>
                  <button type="button" id="delTodo" @click.prevent="delTodo(data.uuid)">Delete</button>
                </td>
              </tr>
              <tr>
                <td colspan="4" id="dataload" style="display:none"></td>
              </tr>
            </table>
          </div>
          <div id="myModal" class="modal">
            <div class="modal-content">
              <span class="close" @click.prevent="closeTodo">&times;</span>
              <form>
                <div class="container">
                  <label for="Title"><b>Title</b></label>
                  <input type="text" placeholder="Enter Title" id="title" required v-model="title">
                  <label for="Description"><b>Description</b></label>
                  <input type="text" placeholder="Enter Description" id="description" required v-model="description">
                  <input type="hidden" id="uuid">
                  <button type="button" id="submitTodo" @click="updateFlag ? updateTodo() : createTodo()">Submit</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
</template>

<script>
export default {
  mounted() {
    this.todos()
  },
  data()
  {
    return {
      uuid      : null,
      email     : null,
      password  : null,
      title     : null,
      description: null,
      datas     : [],
      dataload  : null,
      updateFlag: false,
      token     : localStorage.getItem('access_token') ? localStorage.getItem('access_token') : null,
      api       : 'http://localhost:8081/api'
    }
  },

  methods: {
    todos()
    {
      const self = this
      if(self.token !== null) {
        const dataload = document.getElementById("dataload")

        dataload.innerHTML = 'Please wait..'

        fetch(self.api + '/todo', {
          method    : 'GET',
          headers   : {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + self.token
          }
        })
        .then(function(req){
          if(req.status == 200){
            req.json().then(function( resp ){
              self.datas = resp.data
              if(resp.data.length === 0){
                dataload.innerHTML = 'No data'
              }}
              .bind(this));
          } else if(req.status == 401){
            this.logout()
            req.json().then(function( resp ){alert(resp.message)}.bind(this))
          } else {
            req.json().then(function( resp ){alert(resp.message)}.bind(this))
          }
        })
      }
    },

    login()
    {
      const self = this
      const xbtn    = document.getElementById("login")
      xbtn.disabled = true
      xbtn.innerHTML= 'Please wait...'

      fetch(self.api + '/login', {
        method    : 'POST',
        headers   : {
          'Content-Type': 'application/json'
        },
        body : JSON.stringify({
          email   : self.email,
          password: self.password
        })
      })
      .then(function(req){
        if(req.status !== 200){
          req.json().then(function( resp ){alert(resp.message)}.bind(this));
        } else {
          req.json().then(function( resp ){
            self.token = resp.data.access_token
            localStorage.setItem('access_token', resp.data.access_token)
          }
          .bind(this));
        }
        xbtn.disabled   = false
        xbtn.innerHTML  = 'Login'
      })
    },

    logout()
    {
      this.token = null
      localStorage.removeItem('access_token')
    },
    
    showpass()
    {
      const xPassword = document.querySelector("#showpassword")
      const password  = document.querySelector("#password") 
      if(password.getAttribute("type") === "password") {
        password.setAttribute("type", 'text')
        xPassword.innerHTML = 'Hide Password'
      } else {
        password.setAttribute("type", 'password')
        xPassword.innerHTML = 'Show Password?'
      }
    },

    showTodo()
    {
      const modal = document.querySelector("#myModal")
      modal.style.display = "block"
    },
    
    closeTodo()
    {
      const modal = document.querySelector("#myModal")
      modal.style.display = "none"
    },

    reloadPage() {
      window.location.reload();
    },

    createTodo()
    {
      const self = this
      const xbtn = document.getElementById("submitTodo")

      xbtn.disabled = true
      self.updateFlag= false
      xbtn.innerHTML= 'Please wait...'

      fetch(self.api + '/todo', {
        method    : 'POST',
        headers   : {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + self.token
        },
        body : JSON.stringify({
          title      : self.title,
          description: self.description
        })
      })
      .then(function(req){
        if(req.status == 201) {
          req.json().then(function( resp ){
            alert(resp.message);
            self.reloadPage()
          }.bind(this));
          self.closeTodo()
        } else if(req.status == 401) {
          self.logout()
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        } else {
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        }
        xbtn.disabled   = false
        xbtn.innerHTML  = 'Submit'
      })
    },

    delTodo(id)
    {
      confirm('are you sure delete?')
      
      const self  = this      
      self.datas  = []
      const dataload = document.getElementById("dataload")
      
      dataload.style.display  = ''
      dataload.innerHTML      = 'Please wait'

      fetch(self.api + '/todo/' + id, {
        method    : 'DELETE',
        headers   : {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + self.token
        }
      })
      .then(function(req){
        if(req.status == 200){
          req.json().then(function( resp ){
            alert(resp.message)
            self.reloadPage()
          }
          .bind(this));
        } else if(req.status == 401){
          this.logout()
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        } else {
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        }
      })
    },

    getTodo(id)
    {
      const self  = this
      const title = document.getElementById("title")
      const desc  = document.getElementById("description")
      const idx   = document.getElementById("uuid")
      const xbtn  = document.getElementById("submitTodo")
      
      xbtn.disabled = true
      title.disabled= true
      desc.disabled = true
      xbtn.innerHTML= 'Please wait...'

      self.showTodo()

      fetch(self.api + '/todo/' + id, {
        method    : 'GET',
        headers   : {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + self.token
        }
      })
      .then(function(req){
        if(req.status == 200){
          req.json().then(function( resp ){
            title.value = resp.data.title
            desc.value  = resp.data.description
            idx.uuid    = resp.data.uuid
            self.uuid   = resp.data.uuid
            xbtn.disabled = false
            title.disabled= false
            desc.disabled = false
            self.updateFlag= true
            xbtn.innerHTML= 'Submit'
          }
          .bind(this));
        } else if(req.status == 401){
          this.logout()
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        } else {
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        }
      })
    },

    updateTodo()
    {
      const self = this
      const xbtn = document.getElementById("submitTodo")

      xbtn.disabled = true
      xbtn.innerHTML= 'Please wait...'

      fetch(self.api + '/todo/' + self.uuid, {
        method    : 'PUT',
        headers   : {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + self.token
        },
        body : JSON.stringify({
          title      : self.title,
          description: self.description
        })
      })
      .then(function(req){
        if(req.status == 200) {
          req.json().then(function( resp ){
            self.reloadPage()
            alert(resp.message);
          }.bind(this));
          self.closeTodo()
        } else if(req.status == 401) {
          self.logout()
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        } else {
          req.json().then(function( resp ){alert(resp.message)}.bind(this))
        }
        xbtn.disabled   = false
        xbtn.innerHTML  = 'Submit'
      })
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  width:100%;
}

body {
  background-color: #006694;
  font-family: Arial, Helvetica, sans-serif;
}

.wrap {
  padding:20px;
}

form {
  position: justify;
  text-align: left;
  margin: 10% auto;
  max-width: 50%;
  background-color: #f7f7f7;
  border: 3px solid #f1f1f1;
}

.dashboard {
  position: justify;
  text-align: left;
  margin: 10% auto;
  max-width: 75%;
  background-color: #f7f7f7;
  border: 3px solid #f1f1f1;
}

input[type=text], input[type=password] {
  width: 100%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  box-sizing: border-box;
}

button {
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  cursor: pointer;
  width: 100%;
  background-color: #006694;
  border-color: 1px solid #006694;
}

button:hover {
  opacity: 0.8;
  color:#006694;
  background-color: #f7f7f7;
  border-color: 1px solid #006694;
}

.container {
  padding: 16px;
}

span.password {
  float: right;
  padding-top: 16px;
}

.btn-dashboard {
  display: flex;
  width:100%;
}

.btn-dashboard button {
  background-color: #04AA6D;
  border: none;
}

.btn-dashboard button:hover {
  color: #fff;
}

.btn-create {
  width: 50%;
  text-align: left;
  margin: 5px;
}

.btn-logout {
  width: 50%;
  text-align: right;
  margin:5px;
}

.btn-logout button {
  background-color: #c9302c;
}

.table {
  margin: 0 auto;
  width: 100%;
}

table {
  position: justify;
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
  margin-bottom: 20px;
}

th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

td {
  text-align: left;
  padding: 8px;
}

#dataload {
  text-align: center;
}

.modal {
  display: none;
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgb(0,0,0);
  background-color: rgba(0,0,0,0.4);
}

.modal-content {
  background-color: #fefefe;
  margin: 5% auto;
  padding: 20px;
  border: 1px solid #888;
  width: 80%;
}

.modal-content form {
  position: justify;
  text-align: left;
  max-width: 75%;
  background-color: #fefefe;
  border: none;
}

button#submitTodo {
  background-color: #616161!important;
  border: none;
}

button#getTodo {
  background-color: #616161!important;
  border: none;
}

button#delTodo {
  background-color: #616161!important;
  border: none;
}

button#submitTodo:hover {
  color: #fff;
}

button#getTodo:hover {
  color: #fff;
}

button#delTodo:hover {
  color: #fff;
}

.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
}
</style>
