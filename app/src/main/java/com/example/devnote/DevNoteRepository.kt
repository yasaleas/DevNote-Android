package com.example.devnote

import androidx.lifecycle.LiveData
import com.example.devnote.data.Note
import com.example.devnote.data.NoteDao
import com.example.devnote.data.NoteWithProject
import com.example.devnote.data.Project
import com.example.devnote.data.ProjectDao
import com.example.devnote.data.ProjectWithNotesCount

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DevNoteRepository(
    private val projectDao: ProjectDao,
    private val noteDao: NoteDao
) {
    val allProjectsWithCount: LiveData<List<ProjectWithNotesCount>> = projectDao.getProjectsWithNoteCount()
    val allProjects: LiveData<List<Project>> = projectDao.getAllProjects()
    val allNotesWithProject: LiveData<List<NoteWithProject>> = noteDao.getNotesWithProjectNames()

    suspend fun insertProject(project: Project) {
        withContext(Dispatchers.IO) {
            projectDao.insert(project)
        }
    }

    suspend fun insertNote(note: Note) {
        withContext(Dispatchers.IO) {
            noteDao.insert(note)
        }
    }

    suspend fun deleteProject(id: String) {
        withContext(Dispatchers.IO) {
            projectDao.deleteProjectById(id)
        }
    }

    suspend fun fetchGithubRepos(token: String) {
        withContext(Dispatchers.IO) {
            try {
                val authHeader = if (token.startsWith("Bearer ", ignoreCase = true) || token.startsWith("Token ", ignoreCase = true)) {
                    token
                } else {
                    "Bearer $token"
                }

                var page = 1
                while (true) {
                    val repos = com.example.devnote.data.network.RetrofitInstance.api.getAuthenticatedUserRepos(authHeader, page)
                    if (repos.isEmpty()) break

                    for (repo in repos) {
                        val repoId = "gh_${repo.id}"
                        val existing = projectDao.getProjectById(repoId)
                        
                        // Parse date if possible
                        val createdTime = try {
                            val sdf = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US)
                            sdf.timeZone = java.util.TimeZone.getTimeZone("UTC")
                            sdf.parse(repo.createdAt ?: "")?.time ?: System.currentTimeMillis()
                        } catch (e: Exception) {
                            System.currentTimeMillis()
                        }

                        val project = Project(
                            id = repoId,
                            name = repo.name,
                            createdAt = createdTime,
                            isGithubRepo = true,
                            githubFullName = repo.fullName,
                            githubUrl = repo.htmlUrl,
                            githubDescription = repo.description,
                            githubLanguage = repo.language
                        )

                        if (existing == null) {
                            projectDao.insert(project)
                        } else {
                            projectDao.update(project)
                        }
                    }
                    page++
                    if (repos.size < 100) break // No more pages
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
