window.onload = function() {
  
  loginButton = document.getElementById("login");
  createButton = document.getElementById("new_user");
  nameField = document.getElementById("username");
  passField = document.getElementById("password");
  userForm = document.getElementById("user_form")
    
  loginButton.addEventListener("click",goLogin);
  createButton.addEventListener("click",goCreate);
  
}

function params(){
  return "?name=" + nameField.value + "&password=" + passField.value;
}

function goLogin() {
  userForm.action = "/verify"
  // location.href = "/verify" + params();
}

function goCreate() {
  userForm.action = "/new_user"
  // location.href = "/new_user" + params();
}

