package com.example.devnote.data

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction

data class ProjectWithNotesCount(
    val id: String,
    val name: String,
    val isGithubRepo: Boolean,
    val githubLanguage: String?,
    val noteCount: Int
)

@Dao
interface ProjectDao {
    @androidx.room.Insert(onConflict = androidx.room.OnConflictStrategy.REPLACE)
    fun insert(project: Project): Long

    @Query("DELETE FROM projects WHERE id = :id")
    fun deleteProjectById(id: String)

    @androidx.room.Update
    fun update(project: Project)

    @Query("SELECT * FROM projects WHERE name = :name AND isGithubRepo = 1 LIMIT 1")
    fun getGithubProjectByName(name: String): Project?

    @Query("SELECT * FROM projects WHERE id = :id LIMIT 1")
    fun getProjectById(id: String): Project?

    @Query("SELECT * FROM projects")
    fun getAllProjects(): LiveData<List<Project>>

    @Query("SELECT * FROM projects")
    fun getAllProjectsSync(): List<Project>

    @Query("""
        SELECT p.id, p.name, p.isGithubRepo, p.githubLanguage, COUNT(n.id) as noteCount 
        FROM projects p 
        LEFT JOIN notes n ON p.id = n.projectId 
        GROUP BY p.id
    """)
    fun getProjectsWithNoteCount(): LiveData<List<ProjectWithNotesCount>>
}
