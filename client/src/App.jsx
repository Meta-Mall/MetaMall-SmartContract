import { EthProvider } from "./contexts/EthContext";
import Demo from "./components/Demo";
import "./App.css";
import { useEffect, useState } from "react";

import { Unity, useUnityContext } from "react-unity-webgl";

import { initializeApp } from "firebase/app";
import firebaseConfig from "./firebaseConfig";
import { getAuth, GoogleAuthProvider, signInWithPopup } from "firebase/auth";


function App() {

  const [firebase] = useState(initializeApp(firebaseConfig));
  const [auth, setAuth] = useState();
  const [googleAuth, setGoogleAuth] = useState();
  const [user, setUser] = useState();

  useEffect(() => {
    setAuth(getAuth(firebase));
    setGoogleAuth(new GoogleAuthProvider());
    //firebase.auth().useDeviceLanguage();
  }, [firebase])

  const { unityProvider } = useUnityContext({
    loaderUrl: "MetaMallCore/Build/MetaMallCore.loader.js",
    dataUrl: "MetaMallCore/Build/MetaMallCore.data",
    frameworkUrl: "MetaMallCore/Build/MetaMallCore.framework.js",
    codeUrl: "MetaMallCore/Build/MetaMallCore.wasm",
  });

  const signIn = () => {
    signInWithPopup(auth, googleAuth)
      .then((result) => {
        // This gives you a Google Access Token. You can use it to access the Google API.
        const credential = GoogleAuthProvider.credentialFromResult(result);
        const token = credential.accessToken;
        // The signed-in user info.
        setUser(result.user);
        // IdP data available using getAdditionalUserInfo(result)
        // ...
      }).catch((error) => {
        // Handle Errors here.
        const errorCode = error.code;
        const errorMessage = error.message;
        // The email of the user's account used.
        const email = error.customData.email;
        // The AuthCredential type that was used.
        const credential = GoogleAuthProvider.credentialFromError(error);
        // ...
      });
  }

  return (
    <>
      <div className="navbar">
        <h1 className="logo">
          Meta Mall
        </h1>
        <h3>
          User: {user?.displayName || 'Guest'}
        </h3>
        <button onClick={signIn} >{user ? "Logout" : "Sign In With Google"}</button>
        
      </div>
      <div>
        <Unity className="unityscreen" unityProvider={unityProvider} />
      </div>
      <EthProvider>

        <div id="App">
          <div className="demo">
            <Demo />
          </div>
        </div>
      </EthProvider>
    </>
  );
}

export default App;
