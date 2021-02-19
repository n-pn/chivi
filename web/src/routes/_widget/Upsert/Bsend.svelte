<script>
  export let value
  export let _orig
  export let power
  export let p_min

  const state_classes = { Thêm: 'success', Sửa: 'primary', Xoá: 'harmful' }

  $: power_class = power < p_min ? 'text' : power == p_min ? 'line' : 'solid'
  $: state = !value ? 'Xoá' : _orig ? 'Sửa' : 'Thêm'
  $: state_class = state_classes[state]
</script>

<button
  class="m-button _large _{state_class} _{power_class}"
  disabled={power < 1}
  on:click>
  <span class="-text">{state}</span>
</button>

<style>
  button {
    margin-left: 0.75rem;
    justify-content: center;
    width: 4rem;
  }
</style>
