package com.example.testing_001.controller;

import com.example.testing_001.model.Course;
import com.example.testing_001.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class CourseController {

    @Autowired
    private CourseService courseService;

    @GetMapping("/")
    public String viewHomePage(Model model) {
        return findPaginated(1, "courseName", "asc", model);
    }

    @GetMapping("/add")
    public String showNewCourseForm(Model model) {
        model.addAttribute("course", new Course());
        return "new_course";
    }

    @PostMapping("/save")
    public String saveCourse(@ModelAttribute("course") Course course) {
        courseService.saveCourse(course);
        return "redirect:/";
    }

    @GetMapping("/update/{id}")
    public String showFormForUpdate(@PathVariable long id, Model model) {
        model.addAttribute("course", courseService.getCourseById(id));
        return "update_course";
    }

    @GetMapping("/delete/{id}")
    public String deleteCourse(@PathVariable long id) {
        courseService.deleteCourseById(id);
        return "redirect:/";
    }

    @GetMapping("/page/{pageNo}")
    public String findPaginated(@PathVariable int pageNo,
                                @RequestParam("sortField") String sortField,
                                @RequestParam("sortDir") String sortDir,
                                Model model) {

        int pageSize = 5;
        Page<Course> page = courseService.findPaginated(pageNo, pageSize, sortField, sortDir);
        List<Course> listCourses = page.getContent();

        model.addAttribute("currentPage", pageNo);
        model.addAttribute("totalPages", page.getTotalPages());
        model.addAttribute("totalItems", page.getTotalElements());
        model.addAttribute("sortField", sortField);
        model.addAttribute("sortDir", sortDir);
        model.addAttribute("reverseSortDir", sortDir.equals("asc") ? "desc" : "asc");
        model.addAttribute("listCourses", listCourses);
        return "index";
    }
}
