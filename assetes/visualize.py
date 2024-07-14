from manim import *

def construct_square_wave(axes, width, height, initial_state, n, color=ORANGE):
    result = VGroup()
    current_state = initial_state
    for seg_num in range(n):
        horz_l = Line(
            start=axes.c2p(seg_num*width, int(current_state)*height),
            end=axes.c2p(seg_num*width + width, int(current_state)*height),
            color=color
        )
        vert_l = Line(
            start=horz_l.get_end(),
            end=axes.c2p(seg_num*width + width, int(not current_state)*height),
            color=color
        )
        current_state = not current_state
        result.add(horz_l)
        result.add(vert_l)
    return result

def uart_sample(value, axes, width, height, color=ORANGE, data_color=GREEN):
    res = VGroup()
    bin_sequence = []
    if isinstance(value, str) and len(value) == 1:
        bin_sequence = bin(ord(value))[2:]
    else:
        bin_sequence = bin(value)[2:]
    
    # start bit
    horz_high = Line(
        start=axes.c2p(0, height), end=axes.c2p(width, height), color=color
    )
    vert_down = Line(
        start=axes.c2p(width, height), end=axes.c2p(width, 0), color=color
    )
    horz_low = Line(
        start=axes.c2p(width, 0), end=axes.c2p(width + width, 0), color=color
    )
    start_tex = Tex(
        "start"
    ).next_to(horz_low, DOWN, buff=.2)

    res.add(horz_high)
    res.add(vert_down)
    res.add(horz_low)
    res.add(start_tex)

    current_pos = width * 2

    for index, val in enumerate(bin_sequence):
        l_horz = Line(
            start=axes.c2p(current_pos, int(val)*height),
            end=axes.c2p(current_pos + width, int(val)*height),
            color=data_color
        )
        current_pos += width
            # still going
        if index + 1 < len(bin_sequence):
            if val != bin_sequence[index + 1]:
                # there's change
                l_vert = Line(
                    start=axes.c2p(current_pos, int(val)*height),
                    end=axes.c2p(current_pos, int(bin_sequence[index+1])*height),
                    color=data_color
                )
                res.add(l_vert)
        res.add(l_horz)
        res.add(DecimalNumber(int(val), num_decimal_places=0).next_to(l_horz, UP))

    # end signal
    l = Line(start=axes.c2p(current_pos, 0), end=axes.c2p(current_pos+width, 0), color=color)
    res.add(l)
    stop_tex = Tex("stop").next_to(l, DOWN, buff=.2)
    res.add(stop_tex)
    current_pos += width
    res.add(
        Line(
            start=axes.c2p(current_pos, 0), end=axes.c2p(current_pos, height), color=color
        )
    )
    res.add(
        Line(
            start=axes.c2p(current_pos, height), end=axes.c2p(current_pos+width, height), color=color
        )
    )
    

    return res


class UART(Scene):
    def construct(self):
        axes = Axes(
            x_range=[0, 12, 1], y_range=[0, 2, 1], axis_config={"color": BLUE}
        )

        value = 'E'
        uart_sig = uart_sample(value=value, axes=axes, width=1, height=.5)

        self.add(axes)
        self.play(Create(uart_sig),Write(Tex(value)), rate_func=linear, run_time=2)
        self.wait()