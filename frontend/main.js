
window.addEventListener('DOMContentLoaded', (event) =>{
    getVisitCount();
})

const productionApiUrl = 'https://cchallresume.azurewebsites.net/api/Cchall_http_func?';
const localApiUrl = 'http://localhost:7071/api/Cchall_http_func';

const getVisitCount = () => {
    let count = 30;

    fetch(productionApiUrl) // requette http vers l'API
        .then(response => response.text()) 
        .then(response => {
            console.log("Website called function API.");
            count = parseInt(response);  // Convertion de la string en  int
            document.getElementById("counter").innerText = count;
        })
        .catch(function (error) {
            console.log(error);
        });

    return count;
}









/*
const getVisitCount = () => {
    let count = 30;
    fetch(localApiUrl).then(response => {
        return response.text()
    }).then(response =>{
        console.log("Website called function API.");
        count =  response.count;
        document.getElementById("counter").innerText = count;
    }).catch(function(error){
        console.log(error);
    });
    return count;
}
*/