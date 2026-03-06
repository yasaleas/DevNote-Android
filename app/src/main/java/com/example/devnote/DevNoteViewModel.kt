package com.example.devnote

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.viewModelScope
import com.example.devnote.data.AppDatabase
import com.example.devnote.data.Note
import com.example.devnote.data.NoteWithProject
import com.example.devnote.data.Project
import com.example.devnote.data.ProjectWithNotesCount
import kotlinx.coroutines.launch

class DevNoteViewModel(application: Application) : AndroidViewModel(application) {
    private val repository: DevNoteRepository
    
    val allProjectsWithCount: LiveData<List<ProjectWithNotesCount>>
    val allProjects: LiveData<List<Project>>
    val allNotesWithProject: LiveData<List<NoteWithProject>>

    init {
        val projectDao = AppDatabase.getDatabase(application).projectDao()
        val noteDao = AppDatabase.getDatabase(application).noteDao()
        repository = DevNoteRepository(projectDao, noteDao)
        allProjectsWithCount = repository.allProjectsWithCount
        allProjects = repository.allProjects
        allNotesWithProject = repository.allNotesWithProject
    }

    fun insertProject(project: Project) = viewModelScope.launch {
        repository.insertProject(project)
    }

    fun insertNote(note: Note) = viewModelScope.launch {
        repository.insertNote(note)
    }

    fun deleteProject(id: String) = viewModelScope.launch {
        repository.deleteProject(id)
    }

    fun fetchGithubRepos(token: String) = viewModelScope.launch {
        repository.fetchGithubRepos(token)
    }
}
