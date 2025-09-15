package com.example.testing_001.service;

import com.example.testing_001.model.Course;
import com.example.testing_001.repository.CourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CourseServiceImpl implements CourseService {

    @Autowired
    private CourseRepository courseRepository;

    @Override
    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }

    @Override
    public void saveCourse(Course course) {
        courseRepository.save(course);
    }

    @Override
    public Course getCourseById(long id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Course not found for id : " + id));
    }

    @Override
    public void deleteCourseById(long id) {
        courseRepository.deleteById(id);
    }

    @Override
    public Page<Course> findPaginated(int pageNum, int pageSize,
                                      String sortField, String sortDirection) {
        Sort sort = sortDirection.equalsIgnoreCase(Sort.Direction.ASC.name())
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();
        Pageable pageable = PageRequest.of(pageNum - 1, pageSize, sort);
        return courseRepository.findAll(pageable);
    }
}
