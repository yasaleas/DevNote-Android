package com.example.devnote.data.network

import retrofit2.http.GET
import retrofit2.http.Header

interface GitHubApiService {
    @GET("user/repos?per_page=100&sort=updated&affiliation=owner")
    suspend fun getAuthenticatedUserRepos(
        @Header("Authorization") token: String,
        @retrofit2.http.Query("page") page: Int
    ): List<GithubRepo>

    @GET("user")
    suspend fun getAuthenticatedUser(
        @Header("Authorization") token: String
    ): GitHubUser
}
