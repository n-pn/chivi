<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import { dboard_ctrl } from '$lib/stores'
</script>

<Slider class="dboard" bind:actived={$dboard_ctrl.actived} />
